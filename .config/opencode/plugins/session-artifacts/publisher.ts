import { formatArtifacts, mergeArtifacts, type Artifact } from "./artifacts"

const MAX_ARTIFACTS_PER_ROOT = 50
const MAX_CACHED_ROOTS = 500

export interface PublisherDependencies {
  waitForIdle(root: string): Promise<void>
  post(root: string, text: string): Promise<void>
  onError?(error: unknown): void
}

export interface Publisher {
  add(root: string, artifacts: readonly Artifact[]): void
  dispose(): void
}

/**
 * Serializes artifact notes per root session.
 *
 * The first `add` for a root schedules one publish. Later adds while it is
 * pending join the same queue, so a turn that creates several artifacts posts
 * one cumulative note. Each note lists the artifacts collected for the root so
 * far, deduplicated and capped at 50.
 *
 * Usage:
 * ```ts
 * const publisher = createPublisher({ waitForIdle, post })
 * publisher.add(rootSessionID, artifacts)
 * ```
 */
export function createPublisher(dependencies: PublisherDependencies): Publisher {
  const artifactsByRoot = new Map<string, Artifact[]>()
  const announcedByRoot = new Map<string, Set<string>>()
  const queues = new Map<string, Promise<void>>()
  let disposed = false

  const evictOldestRoot = () => {
    if (artifactsByRoot.size <= MAX_CACHED_ROOTS) return
    const oldest = artifactsByRoot.keys().next().value
    if (oldest === undefined) return
    artifactsByRoot.delete(oldest)
    announcedByRoot.delete(oldest)
  }

  const publish = async (root: string) => {
    if (disposed) return
    await dependencies.waitForIdle(root)
    if (disposed) return
    const artifacts = artifactsByRoot.get(root)
    if (artifacts === undefined || artifacts.length === 0) return
    const announced = announcedByRoot.get(root) ?? new Set<string>()
    if (artifacts.every((artifact) => announced.has(artifact.url))) return

    await dependencies.post(root, formatArtifacts(artifacts))
    announcedByRoot.set(root, new Set(artifacts.map((artifact) => artifact.url)))
  }

  const schedule = (root: string) => {
    const previous = queues.get(root) ?? Promise.resolve()
    const next = previous
      .catch(() => {})
      .then(() => publish(root))
      .catch((error: unknown) => dependencies.onError?.(error))
    queues.set(root, next)
    void next.finally(() => {
      if (queues.get(root) === next) queues.delete(root)
    })
  }

  return {
    add(root, artifacts) {
      const merged = mergeArtifacts(artifactsByRoot.get(root) ?? [], artifacts)
      artifactsByRoot.set(root, merged.slice(-MAX_ARTIFACTS_PER_ROOT))
      evictOldestRoot()
      schedule(root)
    },
    dispose() {
      disposed = true
    },
  }
}

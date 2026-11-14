import { describe, expect, test } from "bun:test"
import type { Artifact } from "./artifacts"
import { createPublisher } from "./publisher"

const pr = (n: number): Artifact => ({ kind: "pull-request", url: `https://github.com/owner/repo/pull/${n}` })
const issue = (n: number): Artifact => ({ kind: "issue", url: `https://github.com/owner/repo/issues/${n}` })

const flush = () => new Promise((resolve) => setTimeout(resolve, 20))

describe("createPublisher", () => {
  test("posts one cumulative note when several artifacts arrive in one turn", async () => {
    const posts: string[] = []
    let releaseIdle: () => void = () => {}
    const idle = new Promise<void>((resolve) => {
      releaseIdle = resolve
    })
    const publisher = createPublisher({
      waitForIdle: () => idle,
      post: async (_root, text) => {
        posts.push(text)
      },
    })

    publisher.add("root", [pr(1)])
    publisher.add("root", [issue(2)])
    releaseIdle()
    await flush()

    expect(posts).toHaveLength(1)
    expect(posts[0]).toContain(pr(1).url)
    expect(posts[0]).toContain(issue(2).url)
  })

  test("posts again when a later turn adds an artifact", async () => {
    const posts: string[] = []
    const publisher = createPublisher({
      waitForIdle: async () => {},
      post: async (_root, text) => {
        posts.push(text)
      },
    })

    publisher.add("root", [pr(1)])
    await flush()
    publisher.add("root", [issue(2)])
    await flush()

    expect(posts).toHaveLength(2)
    expect(posts[1]).toContain(pr(1).url)
    expect(posts[1]).toContain(issue(2).url)
  })

  test("does not post after disposal", async () => {
    const posts: string[] = []
    let releaseIdle: () => void = () => {}
    const idle = new Promise<void>((resolve) => {
      releaseIdle = resolve
    })
    const publisher = createPublisher({
      waitForIdle: () => idle,
      post: async (_root, text) => {
        posts.push(text)
      },
    })

    publisher.add("root", [pr(1)])
    publisher.dispose()
    releaseIdle()
    await flush()

    expect(posts).toEqual([])
  })
})

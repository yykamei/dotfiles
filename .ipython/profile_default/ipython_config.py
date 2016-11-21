# -*- coding: utf-8 -*-
# flake8: noqa

c = get_config()
c.InteractiveShellApp.extensions = ['autoreload']
c.InteractiveShellApp.exec_lines = ['%autoreload 2']

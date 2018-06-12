# frozen_string_literal: true

registry = import('external-lib/registry')

export registry: registry,
       TaskList: registry.TaskList,
       version: '0.0.1'

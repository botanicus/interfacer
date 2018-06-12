# frozen_string_literal: true

# This is not the best naming, ideally we should go with general names over concrete.
# I. e. data_source is a better name than database, but database is still a better name
# tha postgres (in context of components).
export(:interfacer) do
  import('interfacer').Interfacer
end

export(:json_adapter) do
  import('adapters/json')
end

export(:post_repository) do
  # This is a mock, it's useful to start here, but ultimately the registry should only
  # load and instantiate libraries.
  PostRepository = Class.new {
    def retrieve
      <<-EOF
        [
          {"title": "Hello world!"}
        ]
      EOF
    end
  }

  PostRepository.new
end

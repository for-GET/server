.PHONY: all

all:
	@$(MAKE) -f .coffee.mk/coffee.mk $@

sample:
	@bin/server.coffee "./server_config_sample"

COFFEE := $(wildcard *.coffee bin/*.coffee src/*.coffee)
JS := $(patsubst src%, lib%, $(COFFEE:.coffee=.js))

.PHONY: all clean prepublish test testem sample

all: $(JS)

$(JS): $(1)

%.js: %.coffee
	@$(eval input := $<)
	@$(eval output := $@)
	@coffee -pc $(input) > $(output)

clean:
	@rm -f $(JS)

prepublish: clean all

test:
	@mocha --reporter spec test

tap:
	@testem ci

testem:
	@testem

sample:
    @hyperrest-server "./server_config_sample"

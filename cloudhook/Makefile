REBAR := `pwd`/rebar3

all: test release

compile:
	@$(REBAR) compile

doc:
	@$(REBAR) edoc

release:
	@$(REBAR) release

test-all:
	@$(REBAR) do xref, dialyzer, eunit, cover

test:
	@$(REBAR) do xref, eunit, cover

tar:
	@$(REBAR) as prod tar

clean:
	@$(REBAR) clean

shell:
	@$(REBAR) shell

.PHONY: release test all compile clean


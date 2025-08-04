
defmodule TagzUp.Accounts.Token do
  use Ash.Resource,
    domain: TagzUp.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  postgres do
    table "tokens"
    repo TagzUp.Repo
  end

  token do
    domain TagzUp.Accounts
  end
end

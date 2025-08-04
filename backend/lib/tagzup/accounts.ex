
defmodule TagzUp.Accounts do
  use Ash.Domain

  resources do
    resource TagzUp.Accounts.User
    resource TagzUp.Accounts.Token
  end
end

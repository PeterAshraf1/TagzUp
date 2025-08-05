defmodule TagzUp.Business do
  use Ash.Domain

  resources do
    resource TagzUp.Business.BusinessProfile
  end
end
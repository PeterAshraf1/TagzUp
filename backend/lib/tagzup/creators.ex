defmodule TagzUp.Creators do
  use Ash.Domain

  resources do
    resource TagzUp.Creators.InfluencerProfile
    resource TagzUp.Creators.SocialAccount
    resource TagzUp.Creators.Package
    resource TagzUp.Creators.Review
  end
end
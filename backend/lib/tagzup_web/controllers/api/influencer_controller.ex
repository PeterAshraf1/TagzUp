defmodule TagzUpWeb.API.InfluencerController do
  use TagzUpWeb, :controller
  alias TagzUp.Creators.{InfluencerProfile, SocialAccount, Package}

  def index(conn, params) do
    query = params["query"]
    niches = params["niches"] || []
    min_followers = params["min_followers"] && String.to_integer(params["min_followers"])
    max_followers = params["max_followers"] && String.to_integer(params["max_followers"])
    min_engagement = params["min_engagement"] && String.to_float(params["min_engagement"])
    location = params["location"]

    influencers = InfluencerProfile.search!(
      query, niches, min_followers, max_followers, min_engagement, location
    )

    conn
    |> json(%{
      success: true,
      data: Enum.map(influencers, &format_influencer/1)
    })
  end

  def show(conn, %{"id" => id}) do
    case InfluencerProfile.read(id) do
      {:ok, influencer} ->
        social_accounts = SocialAccount.read!()
        |> Enum.filter(&(&1.influencer_profile_id == influencer.id))
        
        packages = Package.active!()
        |> Enum.filter(&(&1.influencer_profile_id == influencer.id))

        conn
        |> json(%{
          success: true,
          data: %{
            influencer: format_influencer(influencer),
            social_accounts: Enum.map(social_accounts, &format_social_account/1),
            packages: Enum.map(packages, &format_package/1)
          }
        })

      {:error, _error} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Influencer not found"})
    end
  end

  def featured(conn, _params) do
    influencers = InfluencerProfile.featured!()

    conn
    |> json(%{
      success: true,
      data: Enum.map(influencers, &format_influencer/1)
    })
  end

  defp format_influencer(influencer) do
    %{
      id: influencer.id,
      display_name: influencer.display_name,
      bio: influencer.bio,
      profile_image_url: influencer.profile_image_url,
      cover_image_url: influencer.cover_image_url,
      location: influencer.location,
      languages: influencer.languages,
      niches: influencer.niches,
      total_followers: influencer.total_followers,
      avg_engagement_rate: influencer.avg_engagement_rate,
      is_featured: influencer.is_featured,
      rating: influencer.rating,
      total_reviews: influencer.total_reviews,
      total_bookings: influencer.total_bookings
    }
  end

  defp format_social_account(account) do
    %{
      id: account.id,
      platform: account.platform,
      username: account.username,
      profile_url: account.profile_url,
      follower_count: account.follower_count,
      engagement_rate: account.engagement_rate,
      verification_status: account.verification_status
    }
  end

  defp format_package(package) do
    %{
      id: package.id,
      title: package.title,
      description: package.description,
      platforms: package.platforms,
      deliverables: package.deliverables,
      price: package.price,
      currency: package.currency,
      delivery_time_days: package.delivery_time_days,
      revisions_included: package.revisions_included,
      post_duration_hours: package.post_duration_hours,
      sample_work_urls: package.sample_work_urls
    }
  end
end
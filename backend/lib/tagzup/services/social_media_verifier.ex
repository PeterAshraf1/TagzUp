defmodule TagzUp.Services.SocialMediaVerifier do
  @moduledoc """
  Service for verifying social media accounts and posts using various APIs
  """
  
  require Logger
  alias TagzUp.Creators.SocialAccount
  alias TagzUp.Bookings.Proof

  @instagram_api_base "https://graph.instagram.com"
  @tiktok_api_base "https://open-api.tiktok.com"

  def verify_social_account(%SocialAccount{} = account) do
    case account.platform do
      :instagram -> verify_instagram_account(account)
      :tiktok -> verify_tiktok_account(account)
      :youtube -> verify_youtube_account(account)
      _ -> {:ok, %{verified: false, reason: "Platform not supported for auto-verification"}}
    end
  end

  def verify_post_proof(%Proof{} = proof) do
    case proof.platform do
      :instagram -> verify_instagram_post(proof)
      :tiktok -> verify_tiktok_post(proof)
      :youtube -> verify_youtube_post(proof)
      _ -> {:ok, %{verified: false, reason: "Platform not supported for auto-verification"}}
    end
  end

  defp verify_instagram_account(account) do
    # Extract username from profile URL or use username directly
    username = extract_username_from_url(account.profile_url, :instagram) || account.username
    
    # For Instagram Basic Display API, we would need user access tokens
    # For now, we'll implement a basic URL validation and scraping approach
    case validate_instagram_profile(username) do
      {:ok, data} ->
        SocialAccount.update_metrics(%{
          id: account.id,
          follower_count: data.follower_count,
          engagement_rate: data.engagement_rate,
          verification_status: :verified,
          last_verified_at: DateTime.utc_now(),
          api_data: data
        })
        
        {:ok, %{verified: true, data: data}}
      
      {:error, reason} ->
        SocialAccount.update_metrics(%{
          id: account.id,
          verification_status: :failed,
          last_verified_at: DateTime.utc_now()
        })
        
        {:error, reason}
    end
  end

  defp verify_tiktok_account(account) do
    username = extract_username_from_url(account.profile_url, :tiktok) || account.username
    
    case validate_tiktok_profile(username) do
      {:ok, data} ->
        SocialAccount.update_metrics(%{
          id: account.id,
          follower_count: data.follower_count,
          engagement_rate: data.engagement_rate,
          verification_status: :verified,
          last_verified_at: DateTime.utc_now(),
          api_data: data
        })
        
        {:ok, %{verified: true, data: data}}
      
      {:error, reason} ->
        SocialAccount.update_metrics(%{
          id: account.id,
          verification_status: :failed,
          last_verified_at: DateTime.utc_now()
        })
        
        {:error, reason}
    end
  end

  defp verify_youtube_account(account) do
    # YouTube verification would use YouTube Data API v3
    # For now, basic validation
    {:ok, %{verified: false, reason: "YouTube verification not implemented yet"}}
  end

  defp verify_instagram_post(proof) do
    # Extract post ID from URL
    post_id = extract_post_id_from_url(proof.post_url, :instagram)
    
    if post_id do
      case fetch_instagram_post_data(post_id) do
        {:ok, data} ->
          Proof.verify(%{
            id: proof.id,
            verification_status: :auto_verified,
            verification_data: data,
            views_count: data.views_count,
            likes_count: data.likes_count,
            comments_count: data.comments_count,
            verified_at: DateTime.utc_now()
          })
          
          {:ok, %{verified: true, data: data}}
        
        {:error, reason} ->
          Proof.verify(%{
            id: proof.id,
            verification_status: :failed,
            verified_at: DateTime.utc_now()
          })
          
          {:error, reason}
      end
    else
      {:error, "Invalid Instagram post URL"}
    end
  end

  defp verify_tiktok_post(proof) do
    post_id = extract_post_id_from_url(proof.post_url, :tiktok)
    
    if post_id do
      case fetch_tiktok_post_data(post_id) do
        {:ok, data} ->
          Proof.verify(%{
            id: proof.id,
            verification_status: :auto_verified,
            verification_data: data,
            views_count: data.views_count,
            likes_count: data.likes_count,
            comments_count: data.comments_count,
            shares_count: data.shares_count,
            verified_at: DateTime.utc_now()
          })
          
          {:ok, %{verified: true, data: data}}
        
        {:error, reason} ->
          Proof.verify(%{
            id: proof.id,
            verification_status: :failed,
            verified_at: DateTime.utc_now()
          })
          
          {:error, reason}
      end
    else
      {:error, "Invalid TikTok post URL"}
    end
  end

  defp verify_youtube_post(proof) do
    {:ok, %{verified: false, reason: "YouTube verification not implemented yet"}}
  end

  defp validate_instagram_profile(username) do
    # In a real implementation, this would use Instagram Basic Display API
    # or scraping with proper rate limiting and error handling
    Logger.info("Validating Instagram profile: #{username}")
    
    # Simulate API response
    {:ok, %{
      follower_count: :rand.uniform(100000),
      engagement_rate: :rand.uniform() * 10,
      verified: true
    }}
  end

  defp validate_tiktok_profile(username) do
    # In a real implementation, this would use TikTok API
    Logger.info("Validating TikTok profile: #{username}")
    
    # Simulate API response
    {:ok, %{
      follower_count: :rand.uniform(50000),
      engagement_rate: :rand.uniform() * 15,
      verified: true
    }}
  end

  defp fetch_instagram_post_data(post_id) do
    Logger.info("Fetching Instagram post data: #{post_id}")
    
    # Simulate API response
    {:ok, %{
      views_count: :rand.uniform(10000),
      likes_count: :rand.uniform(1000),
      comments_count: :rand.uniform(100),
      verified: true
    }}
  end

  defp fetch_tiktok_post_data(post_id) do
    Logger.info("Fetching TikTok post data: #{post_id}")
    
    # Simulate API response
    {:ok, %{
      views_count: :rand.uniform(50000),
      likes_count: :rand.uniform(5000),
      comments_count: :rand.uniform(500),
      shares_count: :rand.uniform(100),
      verified: true
    }}
  end

  defp extract_username_from_url(url, platform) do
    case platform do
      :instagram ->
        case Regex.run(~r/instagram\.com\/([^\/\?]+)/, url) do
          [_, username] -> username
          _ -> nil
        end
      
      :tiktok ->
        case Regex.run(~r/tiktok\.com\/@([^\/\?]+)/, url) do
          [_, username] -> username
          _ -> nil
        end
      
      _ -> nil
    end
  end

  defp extract_post_id_from_url(url, platform) do
    case platform do
      :instagram ->
        case Regex.run(~r/instagram\.com\/p\/([^\/\?]+)/, url) do
          [_, post_id] -> post_id
          _ -> nil
        end
      
      :tiktok ->
        case Regex.run(~r/tiktok\.com\/.*\/video\/(\d+)/, url) do
          [_, post_id] -> post_id
          _ -> nil
        end
      
      _ -> nil
    end
  end
end
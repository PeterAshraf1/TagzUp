defmodule TagzUpWeb.AdminLive do
  use TagzUpWeb, :live_view
  alias TagzUp.Creators.InfluencerProfile
  alias TagzUp.Business.BusinessProfile
  alias TagzUp.Bookings.{Booking, Dispute}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time updates
      Phoenix.PubSub.subscribe(TagzUp.PubSub, "admin_updates")
    end

    socket = 
      socket
      |> assign(:page_title, "Admin Dashboard")
      |> assign(:active_tab, "overview")
      |> load_dashboard_data()

    {:ok, socket}
  end

  def handle_params(%{"tab" => tab}, _uri, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, push_patch(socket, to: ~p"/admin?tab=#{tab}")}
  end

  def handle_event("approve_influencer", %{"id" => id}, socket) do
    case InfluencerProfile.verify(%{id: id, verification_status: :verified}) do
      {:ok, _profile} ->
        socket = 
          socket
          |> put_flash(:info, "Influencer approved successfully")
          |> load_dashboard_data()
        {:noreply, socket}
      
      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to approve influencer")}
    end
  end

  def handle_event("reject_influencer", %{"id" => id}, socket) do
    case InfluencerProfile.verify(%{id: id, verification_status: :rejected}) do
      {:ok, _profile} ->
        socket = 
          socket
          |> put_flash(:info, "Influencer rejected")
          |> load_dashboard_data()
        {:noreply, socket}
      
      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to reject influencer")}
    end
  end

  def handle_event("approve_business", %{"id" => id}, socket) do
    case BusinessProfile.verify(%{id: id, verification_status: :verified}) do
      {:ok, _profile} ->
        socket = 
          socket
          |> put_flash(:info, "Business approved successfully")
          |> load_dashboard_data()
        {:noreply, socket}
      
      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to approve business")}
    end
  end

  def handle_event("reject_business", %{"id" => id}, socket) do
    case BusinessProfile.verify(%{id: id, verification_status: :rejected}) do
      {:ok, _profile} ->
        socket = 
          socket
          |> put_flash(:info, "Business rejected")
          |> load_dashboard_data()
        {:noreply, socket}
      
      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to reject business")}
    end
  end

  defp load_dashboard_data(socket) do
    # Load pending approvals
    pending_influencers = InfluencerProfile.by_verification_status!(:pending)
    pending_businesses = BusinessProfile.by_verification_status!(:pending)
    
    # Load recent bookings
    recent_bookings = Booking.read!() |> Enum.take(10)
    
    # Load open disputes
    open_disputes = Dispute.open_disputes!()
    
    # Calculate stats
    total_influencers = length(InfluencerProfile.by_verification_status!(:verified))
    total_businesses = length(BusinessProfile.by_verification_status!(:verified))
    total_bookings = length(Booking.read!())
    
    socket
    |> assign(:pending_influencers, pending_influencers)
    |> assign(:pending_businesses, pending_businesses)
    |> assign(:recent_bookings, recent_bookings)
    |> assign(:open_disputes, open_disputes)
    |> assign(:total_influencers, total_influencers)
    |> assign(:total_businesses, total_businesses)
    |> assign(:total_bookings, total_bookings)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="bg-white shadow">
        <div class="px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center py-6">
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
              <p class="mt-1 text-sm text-gray-500">Manage TagzUp platform</p>
            </div>
          </div>
        </div>
      </div>

      <div class="px-4 sm:px-6 lg:px-8 py-8">
        <!-- Stats Overview -->
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                    <span class="text-white text-sm font-medium">I</span>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Influencers</dt>
                    <dd class="text-lg font-medium text-gray-900">{@total_influencers}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                    <span class="text-white text-sm font-medium">B</span>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Businesses</dt>
                    <dd class="text-lg font-medium text-gray-900">{@total_businesses}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center">
                    <span class="text-white text-sm font-medium">B</span>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Bookings</dt>
                    <dd class="text-lg font-medium text-gray-900">{@total_bookings}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-red-500 rounded-full flex items-center justify-center">
                    <span class="text-white text-sm font-medium">D</span>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Open Disputes</dt>
                    <dd class="text-lg font-medium text-gray-900">{length(@open_disputes)}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab Navigation -->
        <div class="border-b border-gray-200 mb-6">
          <nav class="-mb-px flex space-x-8">
            <button
              phx-click="change_tab"
              phx-value-tab="overview"
              class={[
                "py-2 px-1 border-b-2 font-medium text-sm",
                @active_tab == "overview" && "border-blue-500 text-blue-600" || "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              ]}
            >
              Overview
            </button>
            <button
              phx-click="change_tab"
              phx-value-tab="influencers"
              class={[
                "py-2 px-1 border-b-2 font-medium text-sm",
                @active_tab == "influencers" && "border-blue-500 text-blue-600" || "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              ]}
            >
              Pending Influencers ({length(@pending_influencers)})
            </button>
            <button
              phx-click="change_tab"
              phx-value-tab="businesses"
              class={[
                "py-2 px-1 border-b-2 font-medium text-sm",
                @active_tab == "businesses" && "border-blue-500 text-blue-600" || "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              ]}
            >
              Pending Businesses ({length(@pending_businesses)})
            </button>
            <button
              phx-click="change_tab"
              phx-value-tab="disputes"
              class={[
                "py-2 px-1 border-b-2 font-medium text-sm",
                @active_tab == "disputes" && "border-blue-500 text-blue-600" || "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              ]}
            >
              Disputes ({length(@open_disputes)})
            </button>
          </nav>
        </div>

        <!-- Tab Content -->
        <div :if={@active_tab == "influencers"} class="bg-white shadow overflow-hidden sm:rounded-md">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Pending Influencer Approvals</h3>
            <div :if={length(@pending_influencers) == 0} class="text-center py-8">
              <p class="text-gray-500">No pending influencer approvals</p>
            </div>
            <ul :if={length(@pending_influencers) > 0} class="divide-y divide-gray-200">
              <li :for={influencer <- @pending_influencers} class="py-4">
                <div class="flex items-center justify-between">
                  <div class="flex items-center">
                    <img 
                      class="h-10 w-10 rounded-full" 
                      src={influencer.profile_image_url || "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop"} 
                      alt=""
                    />
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{influencer.display_name}</div>
                      <div class="text-sm text-gray-500">{influencer.total_followers} followers</div>
                    </div>
                  </div>
                  <div class="flex space-x-2">
                    <button
                      phx-click="approve_influencer"
                      phx-value-id={influencer.id}
                      class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
                    >
                      Approve
                    </button>
                    <button
                      phx-click="reject_influencer"
                      phx-value-id={influencer.id}
                      class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-red-600 hover:bg-red-700"
                    >
                      Reject
                    </button>
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </div>

        <div :if={@active_tab == "businesses"} class="bg-white shadow overflow-hidden sm:rounded-md">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Pending Business Approvals</h3>
            <div :if={length(@pending_businesses) == 0} class="text-center py-8">
              <p class="text-gray-500">No pending business approvals</p>
            </div>
            <ul :if={length(@pending_businesses) > 0} class="divide-y divide-gray-200">
              <li :for={business <- @pending_businesses} class="py-4">
                <div class="flex items-center justify-between">
                  <div class="flex items-center">
                    <img 
                      class="h-10 w-10 rounded-full" 
                      src={business.logo_url || "https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop"} 
                      alt=""
                    />
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{business.company_name}</div>
                      <div class="text-sm text-gray-500">{business.industry || "No industry specified"}</div>
                    </div>
                  </div>
                  <div class="flex space-x-2">
                    <button
                      phx-click="approve_business"
                      phx-value-id={business.id}
                      class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
                    >
                      Approve
                    </button>
                    <button
                      phx-click="reject_business"
                      phx-value-id={business.id}
                      class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-red-600 hover:bg-red-700"
                    >
                      Reject
                    </button>
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </div>

        <div :if={@active_tab == "disputes"} class="bg-white shadow overflow-hidden sm:rounded-md">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Open Disputes</h3>
            <div :if={length(@open_disputes) == 0} class="text-center py-8">
              <p class="text-gray-500">No open disputes</p>
            </div>
            <ul :if={length(@open_disputes) > 0} class="divide-y divide-gray-200">
              <li :for={dispute <- @open_disputes} class="py-4">
                <div class="flex items-center justify-between">
                  <div>
                    <div class="text-sm font-medium text-gray-900">Dispute #{String.slice(dispute.id, 0, 8)}</div>
                    <div class="text-sm text-gray-500">{dispute.reason |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()}</div>
                    <div class="text-xs text-gray-400 mt-1">{dispute.description}</div>
                  </div>
                  <div class="flex space-x-2">
                    <span class={[
                      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                      dispute.status == :open && "bg-red-100 text-red-800" || "bg-yellow-100 text-yellow-800"
                    ]}>
                      {dispute.status |> Atom.to_string() |> String.capitalize()}
                    </span>
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </div>

        <div :if={@active_tab == "overview"} class="space-y-6">
          <!-- Recent Bookings -->
          <div class="bg-white shadow overflow-hidden sm:rounded-md">
            <div class="px-4 py-5 sm:p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Recent Bookings</h3>
              <div :if={length(@recent_bookings) == 0} class="text-center py-8">
                <p class="text-gray-500">No recent bookings</p>
              </div>
              <ul :if={length(@recent_bookings) > 0} class="divide-y divide-gray-200">
                <li :for={booking <- @recent_bookings} class="py-4">
                  <div class="flex items-center justify-between">
                    <div>
                      <div class="text-sm font-medium text-gray-900">Booking #{String.slice(booking.id, 0, 8)}</div>
                      <div class="text-sm text-gray-500">{booking.total_amount} {booking.currency}</div>
                    </div>
                    <span class={[
                      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                      booking.status == :completed && "bg-green-100 text-green-800" ||
                      booking.status == :cancelled && "bg-red-100 text-red-800" ||
                      "bg-yellow-100 text-yellow-800"
                    ]}>
                      {booking.status |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()}
                    </span>
                  </div>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
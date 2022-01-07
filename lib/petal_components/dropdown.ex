defmodule PetalComponents.Dropdown do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias PetalComponents.Heroicons
  import PetalComponents.Link

  @transition_in_base "transition transform ease-out duration-100"
  @transition_in_start "transform opacity-0 scale-95"
  @transition_in_end "transform opacity-100 scale-100"

  @transition_out_base "transition ease-in duration-75"
  @transition_out_start "transform opacity-100 scale-100"
  @transition_out_end "transform opacity-0 scale-95"

  # prop js_lib, :string, default: "alpine_js", options: ["alpine_js", "live_view_js"]
  # prop label, :string
  # prop placement, :string, default: options: ["left", "right"]
  # slot default
  @doc """
    <.dropdown label="Dropdown" js_lib="alpine_js|live_view_js">
      <.dropdown_menu_item link_type="button">
        <Heroicons.Outline.home class="w-5 h-5 text-gray-500" />
        Button item with icon
      </.dropdown_menu_item>
      <.dropdown_menu_item link_type="a" to="/" label="a item" />
      <.dropdown_menu_item link_type="live_patch" to="/" label="Live Patch item" />
      <.dropdown_menu_item link_type="live_redirect" to="/" label="Live Redirect item" />
    </.dropdown>
  """
  def dropdown(assigns) do
    assigns = assigns
      |> assign_new(:options_container_id, fn -> "dropdown_#{Enum.random(1..100000000)}" end)
      |> assign_new(:js_lib, fn -> "alpine_js" end)
      |> assign_new(:placement, fn -> "left" end)

    ~H"""
    <div {js_attributes("container", @js_lib, @options_container_id)} class="relative z-10 inline-block text-left">
      <div>
        <%= if @label do %>
          <button
            link_type="button"
            class="inline-flex justify-center w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none"
            {js_attributes("button", @js_lib, @options_container_id)}
            aria-haspopup="true"
          >
            <%= @label %>
            <Heroicons.Solid.chevron_down class="w-5 h-5 ml-2 -mr-1" />
          </button>
        <% else %>
          <button
            link_type="button"
            class="flex items-center text-gray-400 rounded-full hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-100 focus:ring-indigo-500"
            {js_attributes("button", @js_lib, @options_container_id)}
            aria-haspopup="true"
          >
            <span class="sr-only">Open options</span>
            <Heroicons.Solid.dots_vertical class="w-5 h-5" />
          </button>
        <% end %>
      </div>
      <div
        {js_attributes("options_container", @js_lib, @options_container_id)}
        class={placement_class(@placement) <> " absolute w-56 mt-2 bg-white rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"}
        role="menu"
        id={@options_container_id}
        aria-orientation="vertical"
        aria-labelledby="options-menu"
      >
        <div class="py-1" role="none">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def dropdown_menu_item(assigns) do
    assigns = assigns
      |> assign_new(:link_type, fn -> "button" end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:classes, fn -> dropdown_menu_item_classes() end)
      |> assign_new(:extra_attributes, fn ->
        Map.drop(assigns, [
          :inner_block,
          :link_type,
          :classes,
          :__slot__,
          :__changed__
        ])
      end)

    ~H"""
    <%= if @link_type == "button" do %>
      <button class={@classes}>
        <%= if @inner_block do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          <%= @label %>
        <% end %>
      </button>
    <% else %>
      <.link link_type={@link_type} to={@to} class={@classes} {@extra_attributes}>
        <%= if @inner_block do %>
          <%= render_slot(@inner_block) %>
        <% else %>
          <%= @label %>
        <% end %>
      </.link>
    <% end %>
    """
  end

  defp dropdown_menu_item_classes(),
    do:
      "block flex gap-2 items-center self-start justify-start px-4 py-2 text-sm text-gray-700 transition duration-150 ease-in-out hover:bg-gray-100 w-full text-left"

  defp js_attributes("container", "alpine_js", _options_container_id) do
    %{
      "x-data": "{open: false}",
      "@keydown.escape.stop": "open = false",
      "@click.outside": "open = false"
    }
  end

  defp js_attributes("button", "alpine_js", _options_container_id) do
    %{
      "@click": "open = !open",
      "x-bind:aria-expanded": "open.toString()"
    }
  end

  defp js_attributes("options_container", "alpine_js", _options_container_id) do
    %{
      "x-cloak": true,
      "x-show": "open",
      "x-transition:enter": @transition_in_base,
      "x-transition:enter-start": @transition_in_start,
      "x-transition:enter-end": @transition_in_end,
      "x-transition:leave": @transition_out_base,
      "x-transition:leave-start": @transition_out_start,
      "x-transition:leave-end": @transition_out_end,
    }
  end

  defp js_attributes("container", "live_view_js", options_container_id) do
    %{
      "phx-click-away": JS.hide(
        to: "##{options_container_id}",
        transition: {@transition_out_base, @transition_out_start, @transition_out_end}
      )
    }
  end

  defp js_attributes("button", "live_view_js", options_container_id) do
    %{
      "phx-click": JS.toggle(
        to: "##{options_container_id}",
        display: "block",
        in: {@transition_in_base, @transition_in_start, @transition_in_end},
        out: {@transition_out_base, @transition_out_start, @transition_out_end}
      )
    }
  end

  defp js_attributes("options_container", "live_view_js", _options_container_id) do
    %{
      style: "display: none;",
    }
  end

  defp placement_class("left"), do: "right-0 origin-top-right"
  defp placement_class("right"), do: "left-0 origin-top-left"
end
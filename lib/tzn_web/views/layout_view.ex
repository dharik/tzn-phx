defmodule TznWeb.LayoutView do
  use TznWeb, :view

  def left_nav_button(to, text \\ "", icon, is_active \\ false) do
    if is_active do
      raw("""
      <a
        href="#{to}"
        class="button-block background-dark-600 color-white border-radius font-size-m padding-vertical-s padding-left-s flex align-items-center justify-content-flex-start "
      >
        <span class="material-icons-outlined">#{icon}</span>
        <span class="margin-left-xxs">#{text}</span>
      </a>
      """)
    else
      raw("""
      <a
        href="#{to}"
        class="button-block font-size-m padding-vertical-s padding-left-s flex align-items-center justify-content-flex-start "
      >
        <span class="material-icons-outlined">#{icon}</span>
        <span class="margin-left-xxs">#{text}</span>
      </a>
      """)
    end
  end
end

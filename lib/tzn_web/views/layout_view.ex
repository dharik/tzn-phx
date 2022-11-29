defmodule TznWeb.LayoutView do
  use TznWeb, :view

  def left_nav_button(to, text \\ "", icon, is_active \\ false) do
    if is_active do
      raw("""
      <a
        href="#{to}"
        class="button-block background-dark-600 color-white border-radius font-size-m padding-vertical-s padding-left-s flex align-items-center justify-content-flex-start hover-color-white"
      >
        <span class="material-icons-outlined">#{icon}</span>
        <span class="margin-left-xxs font-weight-bold">#{text}</span>
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

  def left_nav_button_tw(to, text \\ "", icon, is_active \\ false) do
    if is_active do
      raw("""
      <a
        href="#{to}"
        class="bg-white text-blue no-underline hover:no-underline  w-full p-4 pl-16 flex items-center font-medium"
      >
        <span class="material-icons-outlined">#{icon}</span>
        <span class="ml-2">#{text}</span>
      </a>
      """)
    else
      raw("""
      <a
        tabindex="0"
        href="#{to}"
        class="text-off-white no-underline hover:no-underline hover:bg-white hover:text-blue focus:text-blue focus:bg-white w-full p-4 pl-16 flex items-center active:no-underline font-medium duration-200"
      >
        <span class="material-icons-outlined">#{icon}</span>
        <span class="ml-2">#{text}</span>
      </a>
      """)
    end
  end

  def left_nav_button_mentee(to, text \\ "", icon, is_active \\ false) do
    if is_active do
      raw("""
      <span
        class="font-size-m padding-vertical-s padding-left-s flex align-items-center justify-content-flex-start "
      >
        <span class="material-icons">#{icon}</span>
        <span class="margin-left-xxs font-weight-bold">#{text}</span>
      </span>
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

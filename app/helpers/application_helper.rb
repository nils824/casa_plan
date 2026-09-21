module ApplicationHelper
  STATUS_COLORS = {
    "requested" => "bg-amber-100 text-amber-800",
    "confirmed" => "bg-green-100 text-green-800",
    "rejected" => "bg-red-100 text-red-800",
    "withdrawn" => "bg-stone-200 text-stone-700"
  }.freeze

  def status_badge(stay)
    tag.span(stay.status_label, class: "inline-block rounded-full px-2 py-0.5 text-xs font-medium #{STATUS_COLORS[stay.status]}")
  end
end

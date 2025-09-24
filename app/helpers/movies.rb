# app/helpers/movies_helper.rb
module MoviesHelper
  # avg: float (0..5)
  def render_stars(avg)
    full = avg.to_f.floor
    half = (avg.to_f - full) >= 0.5
    empty = 5 - full - (half ? 1 : 0)

    safe_join(
      [
        "★" * full,
        (half ? "☆" : ""),
        "✩" * empty,
        content_tag(:span, number_with_precision(avg, precision: 1), class: "ms-1 small text-muted")
      ]
    )
  end
end

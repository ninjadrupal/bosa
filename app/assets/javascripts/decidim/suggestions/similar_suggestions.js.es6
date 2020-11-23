/**
 * Update similar suggestions cards to open links in new tab
 */
$(() => {
  $(".similar-suggestions .card--suggestion a").each((index, link) => {
    $(link).attr("target", "_blank");
  });
});

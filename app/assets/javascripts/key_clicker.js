$(document).on('ready', function() {
  mapKeyToClick('ArrowUp', $('.buy_btn'));
  mapKeyToClick('ArrowDown', $('.sell_btn'));
  mapKeyToClick('ArrowRight', $('.reverse_btn'));
  mapKeyToClick('ArrowLeft', $('.exit_btn'));
});

function mapKeyToClick(key, targetButton) {
  $(document).on('keydown', function(event) {
    if (event.key === key) {
      targetButton[0].click();
    }
  });
}

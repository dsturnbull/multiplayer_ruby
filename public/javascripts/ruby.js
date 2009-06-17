$(function() {
  $("form").submit(function(event) {
    event.preventDefault();

    // command to send to sirb
    var cmd_text = $("#cmd").val();

    // send it there
    $.post("/sirb", { cmd: cmd_text },
      function(data, status) {
        // get a list of lines back, make each one an li
        $.each(data.result, function(i, result) {
          $("#scrollback").append("<li>" + result + "</li>");
        });
      }, "json"
    );

    // some scrolly hax to make it less shitty. still shitty, though.
    var targetOffset = $("#prompt").offset().top;
    $("html,body").attr({scrollTop: targetOffset});
    $("#cmd").focus();

    // like a real shell
    $("#cmd").attr("value", "");
  });
});


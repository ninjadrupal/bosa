const bindAdminInitiativeAnswer = () => {
  // ANSWER DATE TOGGLE
  const $answerDateField = $("form.edit_initiative_answer label[for='initiative_answer_date']").parent();
  const $initiativeSelect = $("form.edit_initiative_answer #initiative_state");
  const $signatureEndDate = $("form.edit_initiative_answer #initiative_signature_end_date");
  const currentSignatureEndDate = $signatureEndDate.val();

  let getState = (element) => {
    // eslint-disable-next-line no-negated-condition
    if (element !== "published") {
      $answerDateField.show();
    } else {
      $answerDateField.hide();
    }

    if (element === "classified") {
      $signatureEndDate.val(new Date().toLocaleDateString("fr-FR"));
    // } else {
    //   $signatureEndDate.val(new Date(currentSignatureEndDate).toLocaleDateString("fr-FR"));
    }
  };

  if ($initiativeSelect.length > 0) {
    getState($initiativeSelect.find(":selected").val());
    $initiativeSelect.on("change", function () {
      // eslint-disable-next-line no-invalid-this
      getState(this.value);
    });
  }
}

$(function() {
  bindAdminInitiativeAnswer()
})

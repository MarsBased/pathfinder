SimpleForm.setup do |config|
  config.wrappers :default, tag: 'div',
                            class: 'form-group',
                            error_class: :warning do |b|
    b.use :html5
    b.use :placeholder
    b.use :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :label_input
    b.use :hint,  wrap_with: { tag: :div, class: 'info-field' }
    b.use :error, wrap_with: { tag: :div, class: 'info-field' }
  end

  config.wrappers :inline_radio_and_checkbox, tag: 'div',
                                              class: 'form-group',
                                              error_class: 'warning' do |b|
    b.use :html5
    b.optional :readonly

    b.use :label
    b.use :input
  end

  config.default_wrapper = :default
  config.wrapper_mappings = {
    check_boxes: :inline_radio_and_checkbox,
    radio_buttons: :inline_radio_and_checkbox
  }

  config.item_wrapper_tag = false
  config.boolean_style = :inline
  config.button_class = 'btn'
  config.error_notification_tag = :div
  config.error_notification_class = 'error_notification'
  config.label_text = lambda { |label, _required, _explicit_label| label }
  config.browser_validations = false
  config.boolean_label_class = 'checkbox'
end

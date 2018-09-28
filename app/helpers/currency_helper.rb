module CurrencyHelper
  def format_currency(value)
    ActiveSupport::NumberHelper.number_to_currency(
      value,
      unit: 'R$',
      format: '%u %n',
      delimiter: '.',
      separator: ','
    )
  end
end

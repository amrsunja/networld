enum CurrencyType {
  usd,
  eur,
  gbp,
  chf,
  cad,
  jpy,
  aud,
  sek,
  nok,
  dkk,
  cny,
  tryLira;

  static CurrencyType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'USD':
        return CurrencyType.usd;
      case 'EUR':
        return CurrencyType.eur;
      case 'GBP':
        return CurrencyType.gbp;
      case 'CHF':
        return CurrencyType.chf;
      case 'CAD':
        return CurrencyType.cad;
      case 'JPY':
        return CurrencyType.jpy;
      case 'AUD':
        return CurrencyType.aud;
      case 'SEK':
        return CurrencyType.sek;
      case 'NOK':
        return CurrencyType.nok;
      case 'DKK':
        return CurrencyType.dkk;
      case 'CNY':
        return CurrencyType.cny;
      case 'TRY':
        return CurrencyType.tryLira;
      default:
        return CurrencyType.usd;
    }
  }

  String get dbValue {
    switch (this) {
      case CurrencyType.usd:
        return 'USD';
      case CurrencyType.eur:
        return 'EUR';
      case CurrencyType.gbp:
        return 'GBP';
      case CurrencyType.chf:
        return 'CHF';
      case CurrencyType.cad:
        return 'CAD';
      case CurrencyType.jpy:
        return 'JPY';
      case CurrencyType.aud:
        return 'AUD';
      case CurrencyType.sek:
        return 'SEK';
      case CurrencyType.nok:
        return 'NOK';
      case CurrencyType.dkk:
        return 'DKK';
      case CurrencyType.cny:
        return 'CNY';
      case CurrencyType.tryLira:
        return 'TRY';
    }
  }

  String get symbol {
    switch (this) {
      case CurrencyType.eur:
        return '€';
      case CurrencyType.usd:
        return '\$';
      case CurrencyType.gbp:
        return '£';
      case CurrencyType.chf:
        return 'CHF';
      case CurrencyType.cad:
        return 'CA\$';
      case CurrencyType.jpy:
        return '¥';
      case CurrencyType.aud:
        return 'A\$';
      case CurrencyType.sek:
      case CurrencyType.nok:
      case CurrencyType.dkk:
        return 'kr';
      case CurrencyType.cny:
        return '¥';
      case CurrencyType.tryLira:
        return '₺';
    }
  }
}


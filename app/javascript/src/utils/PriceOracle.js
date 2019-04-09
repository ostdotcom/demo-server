import BigNumber from 'bignumber.js';

const P_OST = 5,
  P_OST_ROUND_ROUNDING_MODE = BigNumber.ROUND_HALF_UP,
  P_BT = 5,
  P_BT_ROUND_ROUNDING_MODE = BigNumber.ROUND_HALF_UP,
  P_FIAT = 2,
  P_FIAT_ROUND_ROUNDING_MODE = BigNumber.ROUND_HALF_UP,
  P_DECIMALS = 18;

class PriceOracle {
  ost_to_fiat = 1;
  ost_to_bt = 1;

  constructor(config) {
    if (config.ost_to_fiat) {
      this.ost_to_fiat = String(config.ost_to_fiat);
    }
    if (config.ost_to_bt) {
      this.ost_to_bt = String(config.ost_to_bt);
    }
    this.decimals = P_DECIMALS;
    if (config.decimals) {
      this.decimals = config.decimals;
    }
  }

  ostToFiat(ost) {
    if (!ost) return '';

    ost = BigNumber(ost);

    let result = ost.multipliedBy(this.ost_to_fiat);

    return this.toFiat(result);
  }

  btToFiat(bt) {
    if (!bt) return '';

    bt = BigNumber(bt);
    let fiatBN = BigNumber(this.ost_to_fiat),
      oneBTToFiat = fiatBN.dividedBy(this.ost_to_bt),
      result = oneBTToFiat.multipliedBy(bt);

    return this.toFiat(result);
  }

  btToFiatPrecession(bt) {
    if (!bt) return '';

    let fiat = this.btToFiat(bt);

    return this.toPrecessionFiat(fiat);
  }

  ostToBt(ost) {
    if (!ost) return '';

    ost = BigNumber(ost);

    let result = ost.multipliedBy(this.ost_to_bt);

    return this.toBT(result);
  }

  ostToBtPrecession(ost) {
    if (!ost) return '';

    let result = this.ostToBt(ost);

    return this.toPrecessionBT(result);
  }

  btToOst(bt) {
    if (!bt) return '';

    bt = BigNumber(bt);

    let result = bt.dividedBy(this.ost_to_bt);

    return this.toOst(result);
  }

  btToOstPrecession(bt) {
    if (!bt) return '';

    let result = this.btToOst(bt);

    return this.toPrecessionOst(result);
  }

  toBT(bt) {
    if (this.isNaN(bt)) {
      return NaN;
    }
    bt = BigNumber(bt);
    return bt.toString();
  }

  toPrecessionBT(bt) {
    bt = this.toBT(bt);
    if (!bt) {
      return '';
    }
    bt = BigNumber(bt);
    return bt.toFixed(P_BT, P_BT_ROUND_ROUNDING_MODE);
  }

  toOst(ost) {
    if (this.isNaN(ost)) {
      return '';
    }

    ost = BigNumber(ost);
    return ost.toString();
  }

  toPrecessionOst(ost) {
    ost = this.toOst(ost);
    if (!ost) {
      return '';
    }
    ost = BigNumber(ost);
    return ost.toFixed(P_OST, P_OST_ROUND_ROUNDING_MODE);
  }

  toFiat(fiat) {
    if (this.isNaN(fiat)) {
      return NaN;
    }

    fiat = BigNumber(fiat);
    return fiat.toString();
  }

  toPrecessionFiat(fiat) {
    fiat = this.toFiat(fiat);

    if (!fiat) {
      return '';
    }

    fiat = BigNumber(fiat);
    var precession = this.getFiatPrecession();
    return fiat.toFixed(precession, P_FIAT_ROUND_ROUNDING_MODE);
  }

  fromWei(val) {
    return this.__fromWei__(val);
  }

  toWei(val) {
    return this.__toWei__(val);
  }

  isNaN(val) {
    return typeof val === 'undefined' || val === '' || val === null || isNaN(val);
  }

  getOstPrecession() {
    return P_OST;
  }

  //Keeping FIAT precession as configurable as it can be asked for
  getFiatPrecession() {
    return P_FIAT || P_FIAT;
  }

  getBtPrecession() {
    return P_BT;
  }

  //Private method START
  __fromWei__(val) {
    let exp;

    if (this.isNaN(val)) {
      return NaN;
    }

    val = BigNumber(val);
    exp = BigNumber(10).exponentiatedBy(this.decimals);
    return val.dividedBy(exp).toString(10);
  }

  __toWei__(val) {
    let exp;

    if (this.isNaN(val)) {
      return NaN;
    }

    val = BigNumber(val);
    exp = BigNumber(10).exponentiatedBy(this.decimals);
    return val.multipliedBy(exp).toString(10);
  }
  //Private method END
}

export default PriceOracle;

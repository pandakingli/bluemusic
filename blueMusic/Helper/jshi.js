
function sayHi() {
      
      return 'jsHi'
    }

function zfill(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
}


function expmod( base, exp, mymod ) {
    if ( equalsInt(exp, 0) == 1) return int2bigInt(1,10);
    if ( equalsInt(mod(exp, int2bigInt(2,10) ), 0) ) {
        var newexp = dup(exp);
        rightShift_(newexp,1);
        var result = powMod(expmod( base, newexp, mymod), [2,0], mymod);
        return result;
    }
    else {
        var result = mod(mult(expmod( base, sub(exp, int2bigInt(1,10)), mymod), base), mymod);
        return result;
    }
}

function rsa_encrypt(text, pubKey, modulus) {
    text = text.split('').reverse().join('');
    var base = str2bigInt(hexify(text), 16);
    var exp = str2bigInt(pubKey, 16);
    var mod = str2bigInt(modulus, 16);
    var bigNumber = expmod(base, exp, mod);
    var rs = bigInt2str(bigNumber, 16);
    return zfill(rs, 256).toLowerCase();
}


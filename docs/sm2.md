
# SM2 商用密码算法

## 变革
SM2 算法标准有两个版本，旧标准的加密结果排序为：C1C2C3。新标准为：C1C3C2，其中C1为65字节第1字节为压缩标识，采用无压缩格式存储时固定为 '0x04'，其后 64 字节为为 x、y 分量，各分量都是 32 字节；C3 长 32 字节；C2 长度与原文一致。

## 基础知识
密钥长度：
    私钥0x20(32字节)
    公钥0x41(65字节)    
        SM2 公钥格式字节串长度为65字节，非压缩格式公钥首字节为 '0x04'。压缩格式长度为 33 字节，首字节有两种取值；若公钥 y 坐标最后一位为 0，则首字节为 '0x02'，否则为 '0x03'。
    SM2 公钥一般有两种表示方法：
        拼接为完整字节串： X|Y，或分开展示：公钥 X、公钥 Y。
公钥加密：
    SM2 加密数据将会产生三个值:
        C1 为随机产生的 nounce。
        C2 为密文，与明文长度等长。
        C3 为 SM3 算法对明文数计算得到消息摘要，长度固定为 256 位即 32 字节。
签名数据：
    SM2 加签之后产生的签名为（R,S），这一点与 RSA算法不同，RSA 算法加签之后签名就是一个值。
签名长度：64字节。


## SM2 算法基础

SM2算法是中国国家密码局推出的国产化算法，基于椭圆曲线（Elliptic Curve， EC）的非对称算法，即 SM2 是一种椭圆曲线密码系统算法（Elliptic Curve Cryptograph, ECC）。更具体而言 SM2 找到了一套具有足够优秀特性的椭圆曲线参数。

### ECC 算法基础
ECC 算法的原理可概括为（忽略其中的术语，将点视为大整数坐标对）：
在椭圆曲线上取点 `G` 和 `Q`， 并在椭圆曲线的阿贝尔群空间内，令 `Q`、`G` 符合关系 `Q = DG`。在已知基点 `G` 、大整数（私钥）`D` 的情况下，很容易求得公钥 `Q` ， 而已知 `G`、`Q`，则很难推出 `D`。

加密过程:
密文 `C={rG, M + rQ}`，其中 `r` 是随机数，由于 M + rQ - D(rP) = M + r(DG) - D(rG) = M，即取出密文的 X 坐标，乘以密钥 `D` 以后，从 Y 坐标中减去其值，即得到明文。 


### SM2 椭圆曲线定义
SM2算法定义了两条椭圆曲线，一条基于F§上的素域曲线，一条基于F(2^m)上的拓域曲线，目前使用最多的曲线为素域曲线，本文介绍的算法基于素域曲线上的运算，素域曲线方程定义如下：
y^2 − x^3 + ax + b

### SM2 曲线参数定义
SM2算法定义了5个默认参数，即有限域F§的规模 `p`，椭圆曲线参数 `a`、`b`, 椭圆曲线的基点 `Gxy`（即 `G` 的 x、y 大整数坐标）, 与 `G` 的阶 `n`。

> 标准中给出了对应的默认值如下：
> `p`:  FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF
> `n`:  FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123
> `a`:  FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC
> `b`:  28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93
> `Gx`: 32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7
> `Gy`: BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0

## SM2 计算密文

由前面的说明可知，SM2 密文数据使用公钥 Gxy 加密，密文结构的含义如下：

C1: 随机数 K 与 Gxy 的多倍点运算结果，结果也是一个点记为 (rx, ry)
C2: 实际密文值
C3: 使用SM3对于 rx||data||ry的hash值，在解密时校验解密结果是否正确

### C1
在算法实现中，C1 运算逻辑为 `C1 => (rGx, rGy)`, r 是一个随机数，随机数 r 的取值范围为 [1, n-1]， `n` 是 `G` 的阶。C1 对应算法中加密后报文的 X 分量。

### C2
C2 是真正的密文，计算逻辑如下 `C2 = 密钥流异或 Data`, 密钥流通过已下步骤计算：
1. 复用计算 C1 时产生的随机数 r
2. 计算 rGxy,得到 (rGx，rGy)
3. 根据 Data 的长度与 (rGx, rGy) 生成与 Data 等长的密钥流（公钥 `Q` ）;
4. 密钥流计算采用 KDF 方法，可以理解成根据任意的输入的因子，产生期望长度的数据流，主流的 KDF 计算采用散列算法。
SM2中的 KDF 使用的是 SM 3摘要。

### c3计算逻辑
C3 是 SM3 的散列值，c3 = HASH(rGx, data, rGy)。注意，ECC 算法并不限制散列算法的选择，此处 SM3 的选择并非出于技术意义。

## SM2 计算明文


## 签名
'GM/T 0003.2'： 签名结果为ASN.1(r,s) 形式， 其中 r，s 均为 32 bytes 大整数，共64字节。经过 ASN.1 编码以后长度最长可达72字节。
[GMSSL docs - SM2 数字签名](https://gmssl-docs.readthedocs.io/zh-cn/latest/public_cipher/sm2_sig.html)
sm2_signature_to_der 和 sm2_signature_from_der 函数实现 SM2 签名结果在SM2_SIGNATURE结构和 DER(ASN.1格式) 间相互转换。

```c
    typedef struct {
        uint8_t r[32];
        uint8_t s[32];
    } SM2_SIGNATURE;
```

### 对 SM3 结果签名

a) _Za = SM3 [ENTLA || IDa || a || b || Gx ||Gy || Qx || Qy]。
    - ENTLA : length of IDa in bits (when IDa is default value, it equals to 0x0080 (128 bits))
    - IDa   : Specified id, default to '12345657812345678' (16 bytes/128 bits)
    - a, b  : factors from ECC Curve sm2p256v1 
    - G, Q  : Points on Curve (x-coord | y-coord of BASE POINT and PUBLIC KEY)
b) SM3 HASH : _e := SM3 [_Za]
c) SM3 HASH : h := SM3 [_e||MSG]
d) Signature: Sign(SK)[h] => S := r||s 

解释一下 SM2 against SM3 签名的计算过程：
  - 第一步首先取得如下参数：双方约定的上下文 IDa 的长度 ENTLA（按位计）和 IDa 串，椭圆曲线的参数 a、b，以及椭圆基点 G 和 公钥 Q。所有变量都按照字节串的形式进行拼接，其中 G 和 Q 按照 X、Y 坐标截取对应的字节串（分别为低 32 字节、高 32 字节）。这一步 IDa 可以取默认 '1234567812345678', 对应的长度 ENTLA 的值则固定为 '0x0080' （对应 IDa 的长度：128位）；
  - 对第一步取得的串值 Za 去 SM3 散列 `e`；
  - 再次将散列值 `e` 和 待签名消息 MSG 进行拼接；
  - 计算拼接后字符串的散列值 `h`；
  - 对散列结果执行 SM2 签名，结果低 32 字节为大整数 `r` 的字节串, 高 32 字节为大整数`s` 的字节串。

## ASN.1 编码格式

```python
from asn1crypto.core import Sequence, Integer, IntegerOctetString

class SM2Signature(Sequence):
    _fields = [
        ('r', Integer),
        ('s', Integer)
    ]

class SM2Cryptograhp(Sequence):
    _fields = [
        ('C1', IntegerOctetString),
        ('C2', IntegerOctetString),
        ('C3', IntegerOctetString)
    ]

def signature(bin_content: bytes, asn1 :bool=False) -> str:

    r, s = sing_hash_sm3(data=bin_content)

    if asn1:
        signature = SM2Signature()
        signature['r'] = int.from_bytes(r)
        signature['s'] = int.from_bytes(s)

        sm2_sig = signature.dump(force = True)

    else:
        sm2_sig = r + s

def encrypt_content(bin_content: bytes, asn1 :bool=False) -> bytes:
    C1, C2, C3 = encrypt(data = bin_content)

    if asn1:
        cipher = SM2Cryptograhp()
        cipher['C1'] = int.from_bytes(C1)
        cipher['C2'] = int.from_bytes(C2)
        cipher['C3'] = int.from_bytes(C3)

        sm2_cipher = cipher.dump(force = True)

    else:
        sm2_cipher = C1 + C2 + C3

```


解压缩时：
```python
def decrypt_content(bin_content: bytes, asn1 :bool=False) -> bytes:
    # assert len(bin_content) >= 128

    if asn1:
        cipher = SM2Cryptograhp()
        cipher['C1'] = int.from_bytes(C1)
        cipher['C2'] = int.from_bytes(C2)
        cipher['C3'] = int.from_bytes(C3)

    else:
        C1 = bin_content[:65]
        C2 = bin_content[65:97]
        C3 = bin_content[97:]

    plain_binary = self._cipherware.decrypt(C1 = C1, C2 = C2, C3 = C3)

    return plain_binary
```

参考资料
[椭圆曲线加密算法原理](https://segmentfault.com/a/1190000019172260)
[GmSSL github issue #1038](https://github.com/guanzhi/GmSSL/issues/1038)

https://blog.csdn.net/qq_40964308/article/details/103939700
http://i.goto327.top:85/CryptTools/SM2.aspx

/* gen164/5/ed_scalarmult.c
**
*/
#include "all.h"
#include "urcrypt.h"

/* functions
*/
  static u3_atom
  _cqee_scalarmult(u3_atom a,
                  u3_atom b)
  {
    c3_y a_y[32], b_y[32], out_y[32];

    if ( (0 == u3r_unpack(32, a_y, a)) &&
         (0 == u3r_unpack(32, b_y, b)) &&
         (0 == urcrypt_ed_scalarmult(a_y, b_y, out_y)) ) {
      return u3i_bytes(32, out_y);
    }
    else {
      // hoon does not check size of inputs
      return u3_none;
    }
  }

  u3_noun
  u3wee_scalarmult(u3_noun cor)
  {
    u3_noun a, b;

    if ( (c3n == u3r_mean(cor, u3x_sam_2, &a,
                               u3x_sam_3, &b, 0)) ||
         (c3n == u3ud(a)) ||
         (c3n == u3ud(b)) )
    {
      return u3m_bail(c3__exit);
    } else {
      return _cqee_scalarmult(a, b);
    }
  }

// s0
pub const CHECK_RS1_DEP: u32 = 1;
pub const CHECK_RS2_DEP: u32 = 1 << 1;

// pub enum PreAluASelect {
//     // 3, 2
//     Upper,  // 00
//     Jump,   // 01
//     Branch, // 10
//     RegA,   // 11
// }

// pub enum PreAluBSelect {
//     // 6, 5, 4
//     LowerImmediate,     // 000
//     StoreTypeImmediate, // 001
//     Pc,                 // 10
//     Rs2,                // 011
//     RegA,               // 100
// }

pub enum CmpOp {
    // 9, 8, 7 (branches condition is evaluated in stage 0)
    Equal,                // 001
    NotEqual,             // 010
    LessThan,             // 011
    GreaterEqual,         // 100
    LessThanUnsigned,     // 101
    GreaterEqualUnsigned, // 110
    True,                 // 111
}

// s1
pub const JUMP_IF_BRANCH: u32 = 1 << 10;
pub const MEM_IN_USE: u32 = 1 << 11;

pub enum AluOp {
    // 15, 14, 13, 12
    Add,                 // 0000
    Subtract,            // 0001
    SetLessThanSigned,   // 0010
    SetLessThanUnsigned, // 0011
    Xor,                 // 0100
    Or,                  // 0101
    And,                 // 0110
    ShiftLeft,           // 0111
    ShiftRight,          // 1000
    ShiftRightSignExt,   // 1001
}

// s2
pub const MEM_WRITE_ENABLE: u32 = 1 << 16;
pub const CONNECT_ALU_OUT_TO_MEM_ADDR: u32 = 1 << 17;

// pre writeback select (19:18):
// UpperImmediate, // 00
// AluOut,         // 01
// ReturnAddr,     // 10

// s3
pub const REG_WRITE_ENABLE: u32 = 1 << 20;
pub const USE_PRE_WB_OVER_MEM_DATA: u32 = 1 << 21;

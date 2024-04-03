// s0 (read stage signals)
pub const CHECK_RS1_DEP: u32 = 1;
pub const CHECK_RS2_DEP: u32 = 1 << 1;

pub enum PreAluASelect {
    // 2, 3
    Upper,  // 00
    Jump,   // 01
    Branch, // 10
}

pub enum PreAluBSelect {
    // 4, 5
    LowerImmediate,     // 00
    StoreTypeImmediate, // 01
    Pc,                 // 10
    Rs2,                // 11
}

// s1 (alu stage signals)
pub const CONNECT_PRE_ALU_A_TO_ALU_A: u32 = 1 << 6;
pub const CONNECT_PRE_ALU_B_TO_ALU_B: u32 = 1 << 7;

pub enum AluOp {
    // 8, 9, 10, 11
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

pub enum CmpOp {
    // 12, 13, 14 (branches condition is evaluated in stage 1)
    Equal,                // 001
    NotEqual,             // 010
    LessThan,             // 011
    GreaterEqual,         // 100
    LessThanUnsigned,     // 101
    GreaterEqualUnsigned, // 110
    True,                 // 111
}

// s2 (memory read/write & pc write signals)
pub const MEM_WRITE_ENABLE: u32 = 1 << 15;
pub const CONNECT_ALU_OUT_TO_MEM_ADDR: u32 = 1 << 16;
pub const JUMP_IF_BRANCH: u32 = 1 << 17;
pub const MEM_IN_USE: u32 = 1 << 18; // control unit uses in s3 as well

// s3 (register write-back)
pub const REG_WRITE_ENABLE: u32 = 1 << 19;
pub const CONNECT_UP_TO_REG_DATA_IN: u32 = 1 << 20;
pub const CONNECT_ALU_OUT_TO_REG_DATA_IN: u32 = 1 << 21;
pub const CONNECT_RET_ADDR_TO_REG_DATA_IN: u32 = 1 << 22;
pub const CONNECT_MEM_DATA_OUT_TO_REG_DATA_IN: u32 = 1 << 23;

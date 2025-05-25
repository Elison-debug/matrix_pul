library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_top is
  port(
    -- external pad
    clk_pad         : inout std_logic;
    rst_pad         : inout std_logic;
    read_n_pad      : inout std_logic;
    start_in_pad    : inout std_logic;
    valid_input_pad : inout std_logic;
    r_addr_pad      : inout std_logic_vector(7 downto 0);
    X_load_pad      : inout std_logic_vector(7 downto 0);
    ry_pad          : inout std_logic;
    read_data_pad   : inout std_logic_vector(8 downto 0);
    finish_pad      : inout std_logic
  );
end top_top;

architecture STRUCTURAL of top_top is

  ------------------------------------------------------------------
  -- Pad组件声明
  ------------------------------------------------------------------
  component CPAD_S_74x50u_IN    -- input pad
    port (
      COREIO : out std_logic;
      PADIO  : in  std_logic
    );
  end component;

  component CPAD_S_74x50u_OUT   -- output pad
    port (
      COREIO : in std_logic;
      PADIO  : out std_logic
    );
  end component;

  ------------------------------------------------------------------
  -- modules
  ------------------------------------------------------------------
  component controller
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      start_in      : in  std_logic;
      web           : out std_logic;
      xload_done    : out std_logic;
      ALU_en        : out std_logic;
      input_load_en : out std_logic
    );
  end component;

  component logic_top
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      read_n        : in  std_logic;
      ALU_en        : in  std_logic;
      r_addr        : in  std_logic_vector(7 downto 0);
      X_load        : in  std_logic_vector(7 downto 0);
      valid_input   : in  std_logic;
      input_load_en : in  std_logic;
      web           : in  std_logic;
      xload_done    : out std_logic;
      ry            : out std_logic;
      read_data     : out std_logic_vector(8 downto 0);
      ALU_done      : out std_logic
    );
  end component;

  ------------------------------------------------------------------
  -- inner connecting signals
  ------------------------------------------------------------------
  signal clk_core, rst_core, read_n_core, start_in_core, valid_input_core : std_logic;
  signal ry_core, ALU_done_core, xload_done, ALU_en, input_load_en, web : std_logic;
  signal r_addr_core     : std_logic_vector(7 downto 0);
  signal X_load_core     : std_logic_vector(7 downto 0);
  signal read_data_core  : std_logic_vector(8 downto 0);

begin

  ------------------------------------------------------------------
  --pad instances
  ------------------------------------------------------------------
  clk_pad_inst : CPAD_S_74x50u_IN
    port map (
      COREIO => clk_core,
      PADIO  => clk_pad
    );

  rst_pad_inst : CPAD_S_74x50u_IN
    port map (
      COREIO => rst_core,
      PADIO  => rst_pad
    );

  read_n_pad_inst : CPAD_S_74x50u_IN
    port map (
      COREIO => read_n_core,
      PADIO  => read_n_pad
    );

  start_in_pad_inst : CPAD_S_74x50u_IN
    port map (
      COREIO => start_in_core,
      PADIO  => start_in_pad
    );

  valid_input_pad_inst : CPAD_S_74x50u_IN
    port map (
      COREIO => valid_input_core,
      PADIO  => valid_input_pad
    );

    r_addr_pad_inst : for i in X_load_pad'range generate
    r_addr_pad_gen : CPAD_S_74x50u_IN
    port map (
      COREIO => r_addr_core(i),
      PADIO  => r_addr_pad(i)
    );
  end generate;
    
    X_load_pad_inst : for i in X_load_pad'range generate
    X_load_pad_gen : CPAD_S_74x50u_IN
      port map (
        COREIO => X_load_core(i),
        PADIO  => X_load_pad(i)
      );
  end generate;

  ------------------------------------------------------------------
  -- 输出端 pad 实例化
  ------------------------------------------------------------------
  ry_pad_inst : CPAD_S_74x50u_OUT
    port map (
      COREIO => ry_core,
      PADIO  => ry_pad
    );

  read_data_pad_inst : for i in read_data_pad'range generate
    read_data_pad_gen : CPAD_S_74x50u_OUT
      port map (
        COREIO => read_data_core(i),
        PADIO  => read_data_pad(i)
      );
  end generate;

  finish_pad_inst : CPAD_S_74x50u_OUT
    port map (
      COREIO => ALU_done_core,
      PADIO  => finish_pad
    );

  ------------------------------------------------------------------
  -- 模块实例化
  ------------------------------------------------------------------
  controller_inst : controller
    port map (
      clk           => clk_core,
      rst           => rst_core,
      start_in      => start_in_core,
      web           => web,
      xload_done    => xload_done,
      ALU_en        => ALU_en,
      input_load_en => input_load_en
    );

  logic_top_inst : logic_top
    port map (
      clk           => clk_core,
      rst           => rst_core,
      read_n        => read_n_core,
      r_addr        => r_addr_core,
      ALU_en        => ALU_en,
      X_load        => X_load_core,
      valid_input   => valid_input_core,
      input_load_en => input_load_en,
      web           => web,
      xload_done    => xload_done,
      ry            => ry_core,
      read_data     => read_data_core,
      ALU_done      => ALU_done_core
    );

end STRUCTURAL;

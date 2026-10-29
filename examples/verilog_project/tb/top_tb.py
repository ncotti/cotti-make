import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def reset(dut):
    c = Clock(dut.clk, 10, "ns")
    c.start()
    dut.rstN.value = 0
    dut.ena.value = 0

    await RisingEdge(dut.clk)
    dut.rstN.value = 0
    await RisingEdge(dut.clk)
    dut.rstN.value = 1

@cocotb.test
async def test_read_rom(dut):
    await reset(dut)

    dut.ena.value = 1
    assert dut.addr.value == 0
    assert dut.data.value == 0xFF

    # The design has a 1 cycle delay before starting
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    expected_value = 0x11
    for i in range(1,9):
        await RisingEdge(dut.clk)
        await Timer(1, "ns")

        assert dut.addr.value == i
        assert dut.data.value == expected_value * i

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def reset(dut):
    c = Clock(dut.clk, 10, "ns")
    c.start()
    dut.rstN.value = 0
    dut.ena.value = 0
    dut.load.value = 0
    dut.load_enable.value = 0

    await RisingEdge(dut.clk)
    dut.rstN.value = 0
    await RisingEdge(dut.clk)
    dut.rstN.value = 1
    await RisingEdge(dut.clk)


@cocotb.test
async def test_counter_free_running(dut):
    await reset(dut)

    dut.ena.value = 1

    for i in range(32):
        assert dut.count.value == i
        await RisingEdge(dut.clk)
        await Timer(1, "ns")

    dut.ena.value = 0
    await RisingEdge(dut.clk)
    assert dut.count.value == 32

    await RisingEdge(dut.clk)
    assert dut.count.value == 32


@cocotb.test
async def test_counter_load(dut):
    await reset(dut)

    dut.ena.value = 1
    dut.load_enable.value = 1
    dut.load.value = 0xA0

    assert dut.count.value == 0

    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.count.value == 0xA0

    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.count.value == 0xA0

    dut.load_enable.value = 0

    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.count.value == 0xA1

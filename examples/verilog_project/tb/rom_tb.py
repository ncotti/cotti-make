import cocotb

@cocotb.test
async def test_hello(dut):
    cocotb.log.info("hi")

import cocotb


# test_hello_world
@cocotb.test
async def test_hello_world(dut):
    cocotb.log.info("Hello, World!")
# end test_hello_world
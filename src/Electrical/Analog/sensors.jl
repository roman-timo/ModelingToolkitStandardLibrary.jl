"""
Sensor to measure the current in a branch.
"""
function CurrentSensor(; name)
    @named p = Pin()
    @named n = Pin()
    @variables i(t)=1.0
    eqs = [
        p.v ~ n.v
        i ~ p.i
        i ~ -n.i
    ]
    ODESystem(eqs, t, [i], [], systems=[p, n]; name=name)
end

"""
Sensor to measure the potential.
"""
function PotentialSensor(; name)
    @named p = Pin()
    @variables phi(t)=1.0
    eqs = [
        p.i ~ 0
        phi ~ p.v
    ]
    ODESystem(eqs, t, [phi], [], systems=[p]; name=name)
end

"""
Sensor to measure the voltage between two pins.
"""
function VoltageSensor(; name)
    @named p = Pin()
    @named n = Pin()
    @variables v(t)=1.0
    eqs = [
        p.i ~ 0
        n.i ~ 0
        v ~ p.v - n.v
    ]
    ODESystem(eqs, t, [v], []; systems=[p, n], name=name)
end

"""
Sensor to measure the power
"""
function PowerSensor(; name)
    @named pc = Pin()
    @named nc = Pin()
    @named pv = Pin()
    @named nv = Pin()
    @named voltage_sensor = VoltageSensor()
    @named current_sensor = CurrentSensor()
    @variables power(t)=1.0
    eqs = [
        connect(voltage_sensor.p, pv)
        connect(voltage_sensor.n, nv)
        connect(current_sensor.p, pc)
        connect(current_sensor.n, nc)  
        power ~ current_sensor.i * voltage_sensor.v
    ]
    ODESystem(eqs, t, [power], []; systems=[pc, nc, pv, nv, voltage_sensor, current_sensor], name=name)
end

"""
Sensor to measure current, voltage and power.
"""
function MultiSensor(; name)
    @named pc = Pin()
    @named nc = Pin()
    @named pv = Pin()
    @named nv = Pin()
    @named voltage_sensor = VoltageSensor()
    @named current_sensor = CurrentSensor()
    sts = @variables begin
        i(t)=1.0
        v(t)=1.0
    end
    eqs = [
        connect(voltage_sensor.p, pv)
        connect(voltage_sensor.n, nv)
        connect(current_sensor.p, pc)
        connect(current_sensor.n, nc)
        i ~ current_sensor.i
        v ~ voltage_sensor.v
    ]
    ODESystem(eqs, t, sts, []; systems=[pc, nc, pv, nv, voltage_sensor, current_sensor], name=name)
end

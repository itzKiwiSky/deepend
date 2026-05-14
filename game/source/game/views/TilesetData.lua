return function(batch, config)
    config = config or {}
    local cfg = {
        blendMode = config.blendMode or "alpha",
        useQuads = config.useQuads or false
    }

    return {
        batch = batch,
        config = cfg
    }
end

return function(batch, config)
    config = config or {}
    local cfg = {
        blendMode = config.blendMode or "alpha",
        useQuads = config.useQuads or false,
        rotation = config.rotation or 0,
        scaleX = config.scaleX or 1,
        scaleY = config.scaleY or 1
    }

    return {
        batch = batch,
        config = cfg
    }
end

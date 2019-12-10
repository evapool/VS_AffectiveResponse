    function randomizeList(var)
    
        randomIndex = randperm(length(var.PavCSs)); 
        var.PavCSs = var.PavCSs(randomIndex);
        var.PavSide  = var.PavSide (randomIndex);
        var.PavTrig = var.PavTrig(randomIndex);
        var.PavStim = var.PavStim(randomIndex);     
        
    end
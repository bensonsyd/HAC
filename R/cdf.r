# cdf.r ##################################################################################################################
# FUNCTION: 			DESCRIPTION:
#  pHAC					  Computes the values of the cdf for a given sample and a 'hac' object.
#  .cop.cdf       Supplementary recursive function of pHAC. (Internal function)
#  .one.ob        If X is not a matrix, but a d-dimensional vector, .one.ob modifies X, such that X is a real matrix.
##########################################################################################################################

pHAC = function(X, hac, margins = NULL, na.rm = FALSE, ...){
    
    X = .one.ob(X, margins)    
    if(any(!(colnames(X) %in% .get.leaves(hac$tree)))){stop("The colnames of X have to coincide with the specifications of the copula model hac.")}
	if(na.rm){X = na.omit(X, ...)}
    
    if(hac$type != GAUSS){
        cop = .cop.cdf(X, hac$tree, hac$type)[-1]
        names(cop) = c()
        return(cop)
    }else{ 
        colnames(X) = c()
        return(pcopula(normalCopula(hac$tree[lower.tri(hac$tree)], dim = NCOL(X), dispstr = "un"), X)[-1])
    }
}

#------------------------------------------------------------------------------------------------------------------------

.cop.cdf = function(sample, tree, type){
	if(length(tree)==1){tree = tree[[1]]}
	n = length(tree); names = colnames(sample)
	s = sapply(tree, is.character)

	if(any(s[-n])){
		if(any(!s[-n])){
			select = unlist(tree[s])
				for(i in 1:length(select)){select[i]=(which(names==select[i]))}; select = as.numeric(select)
				exclude = c(1:(n-1))[which(!s[-n])]
			copMult(cbind(sample[, select], sapply(tree[exclude], .cop.cdf, sample = sample[, -select], type = type)), theta = tree[[n]], type = type)
		}else{
			copMult(cbind(sample[, unlist(tree[s])]), theta = tree[[n]], type = type)
	}}else{
		copMult(sapply(tree[-n], .cop.cdf, sample = sample, type = type), theta = tree[[n]], type = type)
	}
}

#------------------------------------------------------------------------------------------------------------------------

.one.ob = function(X, margins = NULL){
    if(class(X) != "matrix"){ 
        names = names(X)
        X = .margins(X, margins)
        names(X) = names
        d = length(names)
        rbind(rep(0.5, d), t(X))
    }else{
        names = colnames(X)
        d = length(names)
        X = .margins(X, margins)
        rbind(rep(0.5, d), X)
    }
}

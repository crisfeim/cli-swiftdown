// Almacena las líneas foldeadas	
const storedContents = new Map();

document.querySelectorAll('.line-number[data-start-line]').forEach(function (endLineNumber) {
    endLineNumber.addEventListener('click', function () {
				const endLineId = endLineNumber.innerText
        const startLineId = endLineNumber.getAttribute('data-start-line');
        const endLine = endLineNumber.parentElement;
				
				// startLine
				const startLine = document.getElementById(startLineId);
				
				// startLineNumber
        const startLineNumber = document.querySelector(`[data-enclosing-line="${endLineId}"]`);
        const codeContainer = endLine.parentElement;
        
        const inBetweenNodes = collectNodesBetween(startLine, endLine, codeContainer);
				
				const codeIsFolded = storedContents.has(startLineNumber);
				if (codeIsFolded) {
					inBetweenNodes.forEach(node => {
						show(node, startLineNumber)
						endLineNumber.classList.remove('folded')
					})
				}
			
    });
});
	
	document.querySelectorAll('.line-number[data-enclosing-line]').forEach(function (startLineNumber) {
	 
		const startLineId = startLineNumber.innerText;
    const startLine = startLineNumber.parentElement;		
		const endLineId = startLineNumber.getAttribute('data-enclosing-line');
    const endLine = document.getElementById(endLineId);
		
		const endLineNumber = document.querySelector(`[data-start-line="${startLineId}"]`);

    const codeContainer = startLine.parentElement;
		
		const shouldHide = startLineNumber.hasAttribute('data-folded')
   
		if (shouldHide) {
			   const inBetweenNodes = collectNodesBetween(startLine, endLine, codeContainer);
				 const codeIsFolded = storedContents.has(startLineNumber);
				 
				 if (!codeIsFolded) {
				 	 // Si los elementos no están ocultos, ocultamos:
            inBetweenNodes.forEach(node => {
							endLineNumber.classList.toggle('folded');
							hide(node, startLineNumber)
            });
				 }
				
		}
   
    startLineNumber.addEventListener('click', function () {
				
        // Colección de nodos a ocultar/mostrar
        const inBetweenNodes = collectNodesBetween(startLine, endLine, codeContainer);
        
        // Comprobar estado actual usando el primer nodo como referencia
        const codeIsFolded = storedContents.has(startLineNumber);
        if (codeIsFolded) {
            // Si los elementos están ocultos, los desocultamos
            inBetweenNodes.forEach(node => {
							show(node, startLineNumber);
							endLineNumber.classList.remove('folded');
						});
        } else {
			
            // Si los elementos no están ocultos, ocultamos:
            inBetweenNodes.forEach(node => {
							endLineNumber.classList.toggle('folded');
							hide(node, startLineNumber)
            });
    
				}
    });
});

// Recolectar nodos entre start y end
function collectNodesBetween(startLine, endLine, codeContainer) {
    const inBetweenNodes = [];
    let shouldCollect = false;

    for (let node of codeContainer.childNodes) {
        if (node === startLine) {
            shouldCollect = true;
            continue;
        }

        if (shouldCollect) {
            if (node === endLine) {
                break;
            }
            inBetweenNodes.push(node);
        }
    }

    return inBetweenNodes;
}

// Helpers
function hide(node, startLineNumber) {
	// Si el nodo es un nodo de texto
	// lo almacenamos en el array y eliminamos su contenido
	if (node.nodeType === Node.TEXT_NODE) {
	    storedContents.set(node, node.textContent);
	    node.textContent = '';
			
	// Si no es un nodo de texto,
	// le añadimos la clase "hidden"
	} else {
	    node.classList.add('hidden');
	   // if (!storedContents.has(startLine)) {
	        storedContents.set(startLineNumber, true);
	    //}
	}
}

function show(node, startLineNumber) {
	if (node.nodeType === Node.TEXT_NODE) {
		node.textContent = storedContents.get(node);
		storedContents.delete(node);
	} else {
		node.classList.remove('hidden');
	}
	storedContents.delete(startLineNumber); 
}
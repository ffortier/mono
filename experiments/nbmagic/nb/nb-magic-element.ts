class NbMagicElement extends HTMLElement {
    static observedAttributes = ["controls", "autoplay"] as const;

    constructor() {
        super();
        const shadow = this.attachShadow({ mode: "open" });

        const style = this.ownerDocument.createElement("style");

        style.textContent = `:host { display: block; }`;

        const restartButton = this.ownerDocument.createElement("button");
        restartButton.type = "button";
        restartButton.append("Restart");

        const runAllButton = this.ownerDocument.createElement("button");
        runAllButton.type = "button";
        runAllButton.append("Run All");

        shadow.append(style, restartButton, runAllButton);
    }

    attributeChangedCallback(
        name: typeof NbMagicElement.observedAttributes[number],
        _oldValue: string | undefined,
        newValue: string | undefined,
    ) {
        // TODO
    }
}

customElements.define("nb-magic", NbMagicElement);

class MyCustomElement extends HTMLElement {
    constructor() {
      super();

      const shadow = this.attachShadow({ mode: "open" });

      const style = document.createElement("style");

      style.textContent = `
        :host {
            display: block;
            background-color: red;
            width: 1em;
            height: 1em;
        }
      `;

      shadow.append(style);
    }
    
    connectedCallback() {

    }
  }

  customElements.define("my-custom", MyCustomElement)
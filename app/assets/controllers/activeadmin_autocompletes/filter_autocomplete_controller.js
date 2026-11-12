import { Controller } from "@hotwired/stimulus";

const OPTION_CLASS =
  "cursor-pointer px-3 py-2 hover:bg-gray-100 dark:hover:bg-gray-800";
const OPTION_ACTIVE_CLASS = "bg-gray-100 dark:bg-gray-800";
const CHIP_CLASS =
  "inline-flex items-center gap-1 rounded-full border border-gray-300 bg-gray-50 px-2 py-0.5 text-sm dark:border-gray-600 dark:bg-gray-800";
const CONTROLLER = "activeadmin-autocompletes--filter-autocomplete";

export default class extends Controller {
  static targets = ["query", "list", "value", "chips", "selected"];
  static values = {
    url: String,
    pageSize: { type: Number, default: 20 },
    multiple: { type: Boolean, default: false },
    params: { type: Object, default: {} },
    paramFields: { type: Object, default: {} },
  };

  static MAX_PAGE_SIZE = 50;
  static MAX_QUERY_CHARS = 200;

  connect() {
    this.activeIndex = -1;
    this.offset = 0;
    this.hasMore = false;
    this.loading = false;
    this.lastQuery = null;
    this.selected = this.readSelected();
    this.renderChips();
    this.boundClearOnDependency = () => this.clearForDependency();
    this.paramFieldElements().forEach((element) => {
      element.addEventListener("change", this.boundClearOnDependency);
      element.addEventListener("input", this.boundClearOnDependency);
    });
  }

  disconnect() {
    clearTimeout(this.timeout);
    this.abortController?.abort();
    this.paramFieldElements().forEach((element) => {
      element.removeEventListener("change", this.boundClearOnDependency);
      element.removeEventListener("input", this.boundClearOnDependency);
    });
  }

  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => this.fetchResults({ reset: true }), 250);
    if (!this.multipleValue && this.hasValueTarget) this.valueTarget.value = "";
  }

  open() {
    this.fetchResults({ reset: true });
  }

  loadMore() {
    if (!this.hasMore || this.loading || this.listTarget.classList.contains("hidden")) {
      return;
    }

    const { scrollTop, scrollHeight, clientHeight } = this.listTarget;
    if (scrollTop + clientHeight < scrollHeight - 24) return;

    this.fetchResults({ reset: false });
  }

  navigate(event) {
    if (event.key === "Backspace" && this.multipleValue && !this.queryTarget.value) {
      const last = this.selected[this.selected.length - 1];
      if (last) this.removeValue(last.value);
      return;
    }

    if (this.listTarget.classList.contains("hidden")) return;

    const options = this.optionElements();
    if (options.length === 0) return;

    if (event.key === "ArrowDown") {
      event.preventDefault();
      this.activeIndex = Math.min(this.activeIndex + 1, options.length - 1);
      this.highlight(options);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      this.activeIndex = Math.max(this.activeIndex - 1, 0);
      this.highlight(options);
    } else if (event.key === "Enter" && this.activeIndex >= 0) {
      event.preventDefault();
      options[this.activeIndex].dispatchEvent(
        new MouseEvent("mousedown", { bubbles: true })
      );
    } else if (event.key === "Escape") {
      this.close();
    }
  }

  async fetchResults({ reset }) {
    const query = this.queryTarget.value.trim().slice(0, this.constructor.MAX_QUERY_CHARS);
    if (reset) {
      this.offset = 0;
      this.hasMore = false;
      this.lastQuery = query;
      this.activeIndex = -1;
    } else if (query !== this.lastQuery) {
      return;
    }

    this.loading = true;
    this.abortController?.abort();
    this.abortController = new AbortController();

    try {
      const url = new URL(this.urlValue, window.location.origin);
      if (query) url.searchParams.set("q", query);
      url.searchParams.set("offset", String(this.offset));
      const limit = Math.min(
        Math.max(Number(this.pageSizeValue) || 20, 1),
        this.constructor.MAX_PAGE_SIZE
      );
      url.searchParams.set("limit", String(limit));
      this.applyExtraParams(url);

      const response = await fetch(url.toString(), {
        headers: { Accept: "application/json" },
        credentials: "same-origin",
        signal: this.abortController.signal,
      });

      if (!response.ok) {
        if (reset) this.close();
        return;
      }

      const items = await response.json();
      const selectedValues = new Set(this.selected.map((item) => String(item.value)));
      const visible = items.filter((item) => !selectedValues.has(String(item.value ?? item.id ?? item.label)));
      this.renderList(visible, { append: !reset });
      this.hasMore = items.length >= limit;
      this.offset += items.length;
      this.setExpanded(true);
    } catch (error) {
      if (error.name !== "AbortError" && reset) this.close();
    } finally {
      this.loading = false;
    }
  }

  applyExtraParams(url) {
    Object.entries(this.paramsValue || {}).forEach(([key, value]) => {
      if (value == null || value === "") return;
      url.searchParams.set(key, String(value));
    });

    Object.entries(this.paramFieldsValue || {}).forEach(([key, selector]) => {
      if (!selector) return;
      const element = document.querySelector(selector);
      const value = element?.value;
      if (value == null || value === "") return;
      url.searchParams.set(key, String(value));
    });
  }

  paramFieldElements() {
    return Object.values(this.paramFieldsValue || {})
      .filter(Boolean)
      .map((selector) => document.querySelector(selector))
      .filter(Boolean);
  }

  clearForDependency() {
    if (this.multipleValue) {
      this.selected = [];
      this.syncSelectedInputs();
      this.renderChips();
    } else if (this.hasValueTarget) {
      this.valueTarget.value = "";
      this.queryTarget.value = "";
    } else {
      this.queryTarget.value = "";
    }
    this.close();
  }

  renderList(items, { append }) {
    if (!append) this.listTarget.replaceChildren();

    items.forEach((item) => {
      const option = document.createElement("li");
      option.className = OPTION_CLASS;
      option.dataset.action = `mousedown->${CONTROLLER}#select`;
      option.dataset.value = item.value ?? item.id ?? item.label;
      option.dataset.label = item.label ?? item.value ?? item.id;
      option.textContent = item.label ?? item.value ?? item.id;
      option.setAttribute("role", "option");
      this.listTarget.appendChild(option);
    });

    if (this.listTarget.children.length === 0) {
      this.close();
      return;
    }

    this.listTarget.classList.remove("hidden");
  }

  select(event) {
    event.preventDefault();
    const { value, label } = event.currentTarget.dataset;
    if (this.multipleValue) {
      this.addValue(value, label || value);
      this.queryTarget.value = "";
      this.close();
      this.queryTarget.focus();
      return;
    }

    if (this.hasValueTarget) {
      this.valueTarget.value = value || "";
      this.queryTarget.value = label || value || "";
    } else {
      this.queryTarget.value = value || "";
    }
    this.close();
  }

  removeChip(event) {
    event.preventDefault();
    this.removeValue(event.currentTarget.dataset.value);
  }

  addValue(value, label) {
    if (!value || this.selected.some((item) => String(item.value) === String(value))) return;
    this.selected = [...this.selected, { value: String(value), label: label || String(value) }];
    this.syncSelectedInputs();
    this.renderChips();
  }

  removeValue(value) {
    this.selected = this.selected.filter((item) => String(item.value) !== String(value));
    this.syncSelectedInputs();
    this.renderChips();
  }

  readSelected() {
    if (!this.multipleValue) return [];
    return this.selectedTargets.map((input) => ({
      value: input.value,
      label: input.dataset.label || input.value,
    }));
  }

  syncSelectedInputs() {
    this.selectedTargets.forEach((input) => input.remove());
    const fieldName = this.element.dataset.fieldName;
    if (!fieldName) return;

    this.selected.forEach((item) => {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = fieldName;
      input.value = item.value;
      input.dataset.label = item.label;
      input.setAttribute(`data-${CONTROLLER}-target`, "selected");
      this.element.appendChild(input);
    });
  }

  renderChips() {
    if (!this.multipleValue || !this.hasChipsTarget) return;
    this.chipsTarget.replaceChildren();
    this.selected.forEach((item) => {
      const chip = document.createElement("span");
      chip.className = CHIP_CLASS;
      const text = document.createElement("span");
      text.textContent = item.label;
      const remove = document.createElement("button");
      remove.type = "button";
      remove.textContent = "×";
      remove.setAttribute("aria-label", `Remove ${item.label}`);
      remove.dataset.value = item.value;
      remove.dataset.action = `click->${CONTROLLER}#removeChip`;
      chip.append(text, remove);
      this.chipsTarget.appendChild(chip);
    });
  }

  close() {
    this.listTarget.classList.add("hidden");
    this.listTarget.replaceChildren();
    this.activeIndex = -1;
    this.setExpanded(false);
  }

  optionElements() {
    return Array.from(this.listTarget.querySelectorAll('[role="option"]'));
  }

  highlight(options) {
    options.forEach((option, index) => {
      option.classList.toggle(OPTION_ACTIVE_CLASS, index === this.activeIndex);
    });
  }

  setExpanded(expanded) {
    this.queryTarget.setAttribute("aria-expanded", expanded ? "true" : "false");
  }
}

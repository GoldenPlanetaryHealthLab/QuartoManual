local callout_titles = {
  ["manual-lib-source"] = "Manual Library Export",
  ["manual-project-source"] = "Project Source Export",
  ["manual-project-test"] = "Project Test Export",
  ["manual-project-script"] = "Project Script Export",
  ["manual-project-config"] = "Project Config Export",
  ["manual-run"] = "Run In This Page",
  ["manual-explain"] = "Why This Step Exists",
}

local callout_classes = {
  ["manual-lib-source"] = "callout-note",
  ["manual-project-source"] = "callout-note",
  ["manual-project-test"] = "callout-warning",
  ["manual-project-script"] = "callout-tip",
  ["manual-project-config"] = "callout-important",
  ["manual-run"] = "callout-tip",
  ["manual-explain"] = "callout-note",
}

function Div(el)
  for class_name, callout_class in pairs(callout_classes) do
    if el.classes:includes(class_name) then
      el.classes:insert("callout")
      el.classes:insert(callout_class)
      if el.attributes["title"] == nil then
        el.attributes["title"] = callout_titles[class_name]
      end
      return el
    end
  end

  return el
end

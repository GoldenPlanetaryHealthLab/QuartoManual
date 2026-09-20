-- Manual fragments are semantic authoring constructs. Their presentation is
-- configured here, but the semantic classes and validation contract remain
-- independent of the chosen renderer.

local fragment_types = {
  ["manual-prereq"] = {
    kind = "prereq",
    presentation = {
      kind = "callout",
      type = "important",
      title = "Prerequisite",
    },
  },
  ["manual-procedure"] = {
    kind = "procedure",
    presentation = {
      kind = "callout",
      type = "tip",
      title = "Procedure",
    },
  },
  ["manual-check"] = {
    kind = "check",
    presentation = {
      kind = "callout",
      type = "warning",
      title = "Check",
    },
  },
  ["manual-explain"] = {
    kind = "explain",
    presentation = {
      kind = "callout",
      type = "note",
      title = "Why This Step Exists",
    },
  },
}

local required_fragment_kinds = {
  prereq = {
    label = "prerequisite",
    expectation = "exactly one",
    minimum = 1,
    maximum = 1,
  },
  procedure = {
    label = "procedure",
    expectation = "at least one",
    minimum = 1,
  },
  check = {
    label = "check",
    expectation = "exactly one",
    minimum = 1,
    maximum = 1,
  },
}

local page_block_counts = nil

local function stringify(value)
  return pandoc.utils.stringify(value)
end

local function is_manual_page()
  local page_number = quarto.metadata.get("manual.page")
  return page_number ~= nil and stringify(page_number) ~= ""
end

local function copy_attr(attr)
  local classes = pandoc.List()
  for _, class_name in ipairs(attr.classes) do
    classes:insert(class_name)
  end

  local attributes = {}
  for name, value in pairs(attr.attributes) do
    attributes[name] = value
  end

  return pandoc.Attr(attr.identifier, classes, attributes)
end

-- Recognition is deliberately independent from the callout renderer. It
-- returns a small semantic representation that later layers can extend with
-- interaction, validation, or provenance information.
local function recognize_fragment(el)
  for class_name, specification in pairs(fragment_types) do
    if el.classes:includes(class_name) then
      return {
        kind = specification.kind,
        source_class = class_name,
        specification = specification,
        content = el.content,
        attr = el.attr,
      }
    end
  end

  return nil
end

local function increment_fragment_count(fragment)
  if page_block_counts ~= nil and page_block_counts[fragment.kind] ~= nil then
    page_block_counts[fragment.kind] = page_block_counts[fragment.kind] + 1
  end
end

local function semantic_attr(fragment)
  local attr = copy_attr(fragment.attr)
  attr.attributes["data-manual-kind"] = fragment.kind
  return attr
end

local function render_callout(fragment)
  local presentation = fragment.specification.presentation
  local attr = semantic_attr(fragment)
  local author_title = attr.attributes["title"]
  local title = author_title or presentation.title

  quarto.log.output(
    "[quarto-manual] rendering "
      .. fragment.source_class
      .. " as callout-"
      .. presentation.type
  )

  return quarto.Callout({
    appearance = attr.attributes["appearance"],
    collapse = attr.attributes["collapse"],
    content = fragment.content,
    icon = attr.attributes["icon"],
    title = title,
    type = presentation.type,
    attr = attr,
  })
end

local function render_semantic_div(fragment)
  return pandoc.Div(fragment.content, semantic_attr(fragment))
end

local function is_markdown_output()
  return quarto.doc.is_format("markdown") or quarto.doc.is_format("gfm")
end

-- Presentation is the only layer that knows that the current output is a
-- Quarto callout. The source semantic class remains on the resulting node.
local function present_fragment(fragment)
  if fragment.specification.presentation.kind == "callout" and not is_markdown_output() then
    return render_callout(fragment)
  end

  return render_semantic_div(fragment)
end

local function warn(message)
  quarto.log.warning("[quarto-manual] " .. message)
end

local function validate_manual_page()
  if not is_manual_page() then
    return
  end

  local input_file = quarto.doc.input_file or "unknown-file"

  for kind, expectation in pairs(required_fragment_kinds) do
    local count = page_block_counts[kind] or 0

    if expectation.maximum ~= nil and count ~= expectation.maximum then
      warn(
        input_file
          .. " should contain "
          .. expectation.expectation
          .. " .manual-"
          .. expectation.label
          .. " block, found "
          .. tostring(count)
          .. "."
      )
    elseif count < expectation.minimum then
      warn(
        input_file
          .. " should contain "
          .. expectation.expectation
          .. " .manual-"
          .. expectation.label
          .. " block, found "
          .. tostring(count)
          .. "."
      )
    end
  end
end

-- Div is the Pandoc AST phase: recognition and semantic normalization happen
-- before the selected format renders the document. This keeps presentation
-- choices out of the source classes and permits a Markdown fallback.
function Div(el)
  local fragment = recognize_fragment(el)
  if fragment == nil then
    return el
  end

  increment_fragment_count(fragment)
  return present_fragment(fragment)
end

function Pandoc(doc)
  page_block_counts = {
    prereq = 0,
    procedure = 0,
    explain = 0,
    check = 0,
  }

  doc = doc:walk({
    Div = Div,
  })

  validate_manual_page()
  page_block_counts = nil

  return doc
end

{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,

  # build system
  poetry-core,

  # dependencies
  beautifulsoup4,
  certifi,
  docling-core,
  docling-ibm-models,
  docling-parse,
  easyocr,
  filetype,
  huggingface-hub,
  lxml,
  marko,
  # ocrmac # not yet packaged
  onnxruntime,
  openpyxl,
  pandas,
  pillow,
  pluggy,
  pydantic,
  pydantic-settings,
  pylatexenc,
  pypdfium2,
  python-docx,
  python-pptx,
  rapidocr-onnxruntime,
  requests,
  rtree,
  scipy,
  tesserocr,
  typer,

  # optional dependencies
  # mkdocs-click # not yet packaged
  mkdocs-jupyter,
  mkdocs-material,
  mkdocstrings,

  # tests
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "docling";
  version = "2.28.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "docling-project";
    repo = "docling";
    tag = "v${version}";
    hash = "sha256-YCZhLrukuQ0Y/4h7v6CfD0oMAfcbioqfs5mU9ImtnNM=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    beautifulsoup4
    certifi
    docling-core
    docling-ibm-models
    docling-parse
    easyocr
    filetype
    huggingface-hub
    lxml
    marko
    # ocrmac # not yet packaged
    onnxruntime
    openpyxl
    pandas
    pillow
    pluggy
    pydantic
    pydantic-settings
    pylatexenc
    pypdfium2
    python-docx
    python-pptx
    rapidocr-onnxruntime
    requests
    rtree
    scipy
    tesserocr
    typer
  ];

  pythonRelaxDeps = [
    "pillow"
    "typer"
  ];

  optional-dependencies = {
    ocrmac = [
      # ocrmac # not yet packaged
    ];
    rapidocr = [
      onnxruntime
      rapidocr-onnxruntime
    ];
    tesserocr = [
      tesserocr
    ];

    docs = [
      # mkdocs-click # not yet packaged
      mkdocs-jupyter
      mkdocs-material
      mkdocstrings
      # griffle-pydantic
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  pythonImportsCheck = [
    "docling"
  ];

  disabledTests = [
    "test_e2e_pdfs_conversions" # AssertionError: ## TableFormer: Table Structure Understanding with Transf
    "test_e2e_conversions" # RuntimeError: Tesseract is not available

    # AssertionError
    # assert doc.export_to_markdown() == pair[1], f"Error in case {idx}"
    "test_ordered_lists"

    # AssertionError: export to md
    "test_e2e_html_conversions"

    # AssertionError: assert 'Unordered li...d code block:' == 'Unordered li...d code block:'
    "test_convert_valid"

    # AssertionError: Markdown file mismatch against groundtruth pftaps057006474.md
    "test_patent_groundtruth"

    # huggingface_hub.errors.LocalEntryNotFoundError: An error happened
    "test_cli_convert"
    "test_code_and_formula_conversion"
    "test_picture_classifier"
    "test_convert_path"
    "test_convert_stream"
    "test_compare_legacy_output"
    "test_ocr_coverage_threshold"

    # requires network access
    "test_page_range"
    "test_parser_backends"

    # AssertionError: pred_itxt==true_itxt
    "test_e2e_valid_csv_conversions"
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # No module named 'torch._C._distributed_c10d'; 'torch._C' is not a package
    "tests/test_backend_csv.py"
    "tests/test_backend_html.py"
    "tests/test_backend_jats.py"
    "tests/test_backend_msexcel.py"
    "tests/test_backend_msword.py"
    "tests/test_backend_pptx.py"
    "tests/test_cli.py"
    "tests/test_code_formula.py"
    "tests/test_document_picture_classifier.py"
    "tests/test_e2e_conversion.py"
    "tests/test_e2e_ocr_conversion.py"
    "tests/test_input_doc.py"
    "tests/test_interfaces.py"
    "tests/test_invalid_input.py"
    "tests/test_legacy_format_transform.py"
    "tests/test_options.py"
  ];

  meta = {
    description = "Get your documents ready for gen AI";
    homepage = "https://github.com/DS4SD/docling";
    changelog = "https://github.com/DS4SD/docling/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "docling";
  };
}

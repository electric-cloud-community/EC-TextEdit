
// ReplaceParameterPanel.java --
//
// ReplaceParameterPanel.java is part of ElectricCommander.
//
// Copyright (c) 2005-2012 Electric Cloud, Inc.
// All rights reserved.
//

package ecplugins.textedit.client;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import com.electriccloud.commander.client.domain.ActualParameter;
import com.electriccloud.commander.client.domain.FormalParameter;
import com.electriccloud.commander.client.util.StringUtil;
import com.electriccloud.commander.gwt.client.ComponentBase;
import com.electriccloud.commander.gwt.client.ui.CustomValueCheckBox;
import com.electriccloud.commander.gwt.client.ui.FormBuilder;
import com.electriccloud.commander.gwt.client.ui.ParameterPanel;
import com.electriccloud.commander.gwt.client.ui.ParameterPanelProvider;
import com.electriccloud.commander.gwt.client.ui.RadioButtonGroup;

public class ReplaceParameterPanel
    extends ComponentBase
    implements ParameterPanel,
        ParameterPanelProvider
{

    //~ Static fields/initializers ---------------------------------------------

    // ~ Static fields/initializers----------------------------
    private static UiBinder<Widget, ReplaceParameterPanel> s_binder = GWT
            .create(Binder.class);

    // These are all the formalParameters on the Procedure
    static final String FILE_PATH   = "file_path";
    static final String FILTERS     = "filters";
    static final String FIND        = "find";
    static final String MATCH_CASE  = "match_case";
    static final String REPLACE     = "replace";
    static final String SEARCH_IN   = "search_in";
    static final String SEARCH_MODE = "search_mode";

    //~ Instance fields --------------------------------------------------------

    // ~ Instance fields
    // --------------------------------------------------------
    @UiField FormBuilder replaceParameterForm;

    //~ Methods ----------------------------------------------------------------

    // ~ Methods
    // ----------------------------------------------------------------
    /**
     * This function is called by SDK infrastructure to initialize the UI parts
     * of this component.
     *
     * @return  A widget that the infrastructure should place in the UI; usually
     *          a panel.
     */
    @Override public Widget doInit()
    {
        Widget                 base        = s_binder.createAndBindUi(this);
        final RadioButtonGroup search_mode = getUIFactory()
                .createRadioButtonGroup("searchMode", "normal",
                    new VerticalPanel());

        search_mode.addRadio("Normal", "normal");
        search_mode.addRadio("Regular Expression", "regex");

        final RadioButtonGroup search_in = getUIFactory()
                .createRadioButtonGroup("searchIn", "single",
                    new VerticalPanel());

        search_in.addRadio("Single File", "single");
        search_in.addRadio("Multiple Files", "multiple");
        search_in.addRadio("Folder", "folder");

        final CustomValueCheckBox match_case = getUIFactory()
                .createCustomValueCheckBox("1", "0");

        replaceParameterForm.addRow(true, "Search Mode:",
            "Search using text or regular expressions. 'Find' will be treated as normal text or a regular expression.",
            SEARCH_MODE, "normal", search_mode);
        replaceParameterForm.addRow(true, "Find:", "Text to find in the file.",
            FIND, "", new TextBox());
        replaceParameterForm.addRow(true, "Replace:", "Replacement text.",
            REPLACE, "", new TextBox());
        replaceParameterForm.addRow(true, "Search In:", "Select where to look",
            SEARCH_IN, "single", search_in);
        replaceParameterForm.addRow(true, "File path:",
            "Path to the file to use.", FILE_PATH, "", new TextBox());

        // File paths, List oft Paths to the files to use, separated with
        // semicolon.
        // Folder path, Path to the folder to use.
        replaceParameterForm.addRow(false, "Filters:",
            "Filter file names and/or extensions.", FILTERS, "*.*",
            new TextBox());
        replaceParameterForm.addRow(false, "Match Case:",
            "Match case of text to find.", MATCH_CASE, "0", match_case);
        search_in.addValueChangeHandler(new ValueChangeHandler<String>() {
                @Override public void onValueChange(
                        ValueChangeEvent<String> event)
                {
                    updateRowVisibility();
                }
            });
        updateRowVisibility();

        return base;
    }

    /**
     * Performs validation of user supplied data before submitting the form.
     *
     * <p>This function is called after the user hits submit.</p>
     *
     * @return  true if checks succeed, false otherwise
     */
    @Override public boolean validate()
    {
        boolean validationStatus = replaceParameterForm.validate();

        // SEARCH_MODE is required.
        if (StringUtil.isEmpty(replaceParameterForm.getValue(SEARCH_MODE))) {
            replaceParameterForm.setErrorMessage(SEARCH_MODE,
                "This Field is required.");
            validationStatus = false;
        }

        // FIND is required.
        if (StringUtil.isEmpty(replaceParameterForm.getValue(FIND)
                                                   .trim())) {
            replaceParameterForm.setErrorMessage(FIND,
                "This Field is required.");
            validationStatus = false;
        }

        // REPLACE is required.
        if (StringUtil.isEmpty(replaceParameterForm.getValue(REPLACE)
                                                   .trim())) {
            replaceParameterForm.setErrorMessage(REPLACE,
                "This Field is required.");
            validationStatus = false;
        }

        // SEARCH_IN is required.
        if (StringUtil.isEmpty(replaceParameterForm.getValue(SEARCH_IN))) {
            replaceParameterForm.setErrorMessage(SEARCH_IN,
                "This Field is required.");
            validationStatus = false;
        }

        // FILE_PATH is required.
        if (StringUtil.isEmpty(
                    replaceParameterForm.getValue(FILE_PATH)
                                    .trim())) {
            replaceParameterForm.setErrorMessage(FILE_PATH,
                "This Field is required.");
            validationStatus = false;
        }

        return validationStatus;
    }

    protected void updateRowVisibility()
    {
        String search = replaceParameterForm.getValue(SEARCH_IN);

        replaceParameterForm.setRowVisible(FILTERS, "folder".equals(search));
        // replaceParameterForm.
    }

    /**
     * This method is used by UIBinder to embed FormBuilder's in the UI.
     *
     * @return  a new FormBuilder.
     */
    @UiFactory FormBuilder createFormBuilder()
    {
        return getUIFactory().createFormBuilder();
    }

    @Override public ParameterPanel getParameterPanel()
    {
        return this;
    }

    /**
     * Gets the values of the parameters that should map 1-to-1 to the formal
     * parameters on the object being called. Transform user input into a map of
     * parameter names and values.
     *
     * <p>This function is called after the user hits submit and validation has
     * succeeded.</p>
     *
     * @return  The values of the parameters that should map 1-to-1 to the
     *          formal parameters on the object being called.
     */
    @Override public Map<String, String> getValues()
    {
        Map<String, String> actualParams      = new HashMap<String, String>();
        Map<String, String> replaceFormValues =
            replaceParameterForm.getValues();

        actualParams.put(FILE_PATH, replaceFormValues.get(FILE_PATH));
        actualParams.put(FILTERS, replaceFormValues.get(FILTERS));
        actualParams.put(FIND, replaceFormValues.get(FIND));
        actualParams.put(MATCH_CASE, replaceFormValues.get(MATCH_CASE));
        actualParams.put(REPLACE, replaceFormValues.get(REPLACE));
        actualParams.put(SEARCH_IN, replaceFormValues.get(SEARCH_IN));
        actualParams.put(SEARCH_MODE, replaceFormValues.get(SEARCH_MODE));

        return actualParams;
    }

    /**
     * Push actual parameters into the panel implementation.
     *
     * <p>This is used when editing an existing object to show existing content.
     * </p>
     *
     * @param  actualParameters  Actual parameters assigned to this list of
     *                           parameters.
     */
    @Override public void setActualParameters(
            Collection<ActualParameter> actualParameters)
    {

        if (actualParameters == null) {
            return;
        }

        // First load the parameters into a map. Makes it easier to
        // update the form by querying for various params randomly.
        Map<String, String> params = new HashMap<String, String>();

        for (ActualParameter p : actualParameters) {
            params.put(p.getName(), p.getValue());
        }

        // Do the easy form elements first.
        for (String key : new String[] {
                    FILE_PATH,
                    FILTERS,
                    FIND,
                    SEARCH_IN,
                    SEARCH_MODE,
                    REPLACE
                }) {
            replaceParameterForm.setValue(key,
                StringUtil.nullToEmpty(params.get(key)));
        }

        // match_case is also an easy direct mapping (but
        // to the top form).
        String match_case = params.get(MATCH_CASE);

        if (match_case == null) {
            match_case = "0";
        }

        replaceParameterForm.setValue(MATCH_CASE, match_case);
        updateRowVisibility();
    }

    /**
     * Push form parameters into the panel implementation.
     *
     * <p>This is used when creating a new object and showing default values.
     * </p>
     *
     * @param  formalParameters  Formal parameters on the target object.
     */
    @Override public void setFormalParameters(
            Collection<FormalParameter> formalParameters) { }

    //~ Inner Interfaces -------------------------------------------------------

    // ~ Inner Interfaces
    // -------------------------------------------------------
    interface Binder
        extends UiBinder<Widget, ReplaceParameterPanel> { }
}

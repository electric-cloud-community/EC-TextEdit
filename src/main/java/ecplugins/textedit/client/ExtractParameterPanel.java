
// ExtractParameterPanel.java --
//
// ExtractParameterPanel.java is part of ElectricCommander.
//
// Copyright (c) 2005-2012 Electric Cloud, Inc.
// All rights reserved.
//

package ecplugins.textedit.client;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;

import com.electriccloud.commander.client.domain.ActualParameter;
import com.electriccloud.commander.client.domain.FormalParameter;
import com.electriccloud.commander.client.util.StringUtil;
import com.electriccloud.commander.gwt.client.ComponentBase;
import com.electriccloud.commander.gwt.client.ui.FormBuilder;
import com.electriccloud.commander.gwt.client.ui.ParameterPanel;
import com.electriccloud.commander.gwt.client.ui.ParameterPanelProvider;

public class ExtractParameterPanel
    extends ComponentBase
    implements ParameterPanel,
        ParameterPanelProvider
{

    //~ Static fields/initializers ---------------------------------------------

    // ~ Static fields/initializers----------------------------
    private static UiBinder<Widget, ExtractParameterPanel> s_binder = GWT
            .create(Binder.class);

    // These are all the formalParameters on the Procedure
    static final String FILE_PATH = "file_path";
    static final String REGEX     = "regex";
    static final String RESULT    = "matches_outpsp";

    //~ Instance fields --------------------------------------------------------

    // ~ Instance fields
    // --------------------------------------------------------
    @UiField FormBuilder extractParameterForm;

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
        Widget base = s_binder.createAndBindUi(this);

        extractParameterForm.addRow(true, "File path:",
            "Path to the file to use.", FILE_PATH, "", new TextBox());
        extractParameterForm.addRow(true, "Regular Expression:",
            "Regular Expression to evaluate.", REGEX, "", new TextBox());
        extractParameterForm.addRow(false,
            "Matches Found (output property sheet path):",
            "Path to the property sheet to save results (default is /myJob/TextEdit/$[jobStepId]/)",
            RESULT, "/myJob/TextEdit/$[jobStepId]/", new TextBox());
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
        boolean validationStatus = extractParameterForm.validate();

        // REGEX is required.
        if (StringUtil.isEmpty(extractParameterForm.getValue(REGEX))) {
            extractParameterForm.setErrorMessage(REGEX,
                "This Field is required.");
            validationStatus = false;
        }

        // FILE_PATH is required.
        if (StringUtil.isEmpty(
                    extractParameterForm.getValue(FILE_PATH)
                                    .trim())) {
            extractParameterForm.setErrorMessage(FILE_PATH,
                "This Field is required.");
            validationStatus = false;
        }

        return validationStatus;
    }

    protected void updateRowVisibility() { }

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
        Map<String, String> extractFormValues =
            extractParameterForm.getValues();

        actualParams.put(FILE_PATH, extractFormValues.get(FILE_PATH));
        actualParams.put(REGEX, extractFormValues.get(REGEX));
        actualParams.put(RESULT, extractFormValues.get(RESULT));

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
        for (String key : new String[] {FILE_PATH, REGEX, RESULT}) {
            extractParameterForm.setValue(key,
                StringUtil.nullToEmpty(params.get(key)));
        }

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
        extends UiBinder<Widget, ExtractParameterPanel> { }
}

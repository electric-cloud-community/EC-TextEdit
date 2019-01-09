
// AddParameterPanel.java --
//
// AddParameterPanel.java is part of ElectricCommander.
//
// Copyright (c) 2005-2012 Electric Cloud, Inc.
// All rights reserved.
//

package ecplugins.textedit.client;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.jetbrains.annotations.NonNls;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;

import com.electriccloud.commander.client.domain.ActualParameter;
import com.electriccloud.commander.client.domain.FormalParameter;
import com.electriccloud.commander.client.util.StringUtil;
import com.electriccloud.commander.gwt.client.ComponentBase;
import com.electriccloud.commander.gwt.client.ui.CustomValueCheckBox;
import com.electriccloud.commander.gwt.client.ui.FormBuilder;
import com.electriccloud.commander.gwt.client.ui.ParameterPanel;
import com.electriccloud.commander.gwt.client.ui.ParameterPanelProvider;
import com.electriccloud.commander.gwt.client.ui.ValuedListBox;

public class AddParameterPanel
    extends ComponentBase
    implements ParameterPanel,
        ParameterPanelProvider
{

    //~ Static fields/initializers ---------------------------------------------

    // ~ Static fields/initializers----------------------------
    private static UiBinder<Widget, AddParameterPanel> s_binder = GWT.create(
            Binder.class);

    // These are all the formalParameters on the Procedure
    @NonNls static final String FILE_PATH       = "file_path";
    @NonNls static final String INSERTION_POINT = "insertion_point";
    @NonNls static final String REGEX           = "regex";
    static final String         SEARCH          = "search";
    static final String         TEXT            = "text";

    //~ Instance fields --------------------------------------------------------

    // ~ Instance fields
    // --------------------------------------------------------
    @UiField FormBuilder addParameterForm;

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
        Widget        base            = s_binder.createAndBindUi(this);
        ValuedListBox insertion_point = getUIFactory().createValuedListBox();

        insertion_point.addItem("At the End", "end");
        insertion_point.addItem("At the Beginning", "beginning");
        insertion_point.addItem("By Search(After)", "search");

        CustomValueCheckBox regex = getUIFactory().createCustomValueCheckBox(
                "1", "0");

        addParameterForm.addRow(true, "File path:", "Path to the file to use.",
            FILE_PATH, "", new TextBox());
        addParameterForm.addRow(true, "Text:", "Text to insert in the file.",
            TEXT, "", new TextBox());
        addParameterForm.addRow(true, "Insertion point:",
            "Select where to add the text: At the End, At the Beginning, By Search(After) ",
            INSERTION_POINT, "end", insertion_point);
        addParameterForm.addRow(false, "Search:",
            "Text to search, after which 'Text' will be added.", SEARCH, "",
            new TextBox());
        addParameterForm.addRow(false, "Regular Expression?:",
            "Search using text or regular expressions. 'Search' will be treated as normal text or a regular expression.",
            REGEX, "0", regex);
        insertion_point.addValueChangeHandler(new ValueChangeHandler<String>() {
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
        boolean validationStatus = addParameterForm.validate();
        String  insertion_point  = addParameterForm.getValue(INSERTION_POINT);

        // TEXT is required.
        if (StringUtil.isEmpty(addParameterForm.getValue(TEXT))) {
            addParameterForm.setErrorMessage(TEXT, "This Field is required.");
            validationStatus = false;
        }

        // FILE_PATH is required.
        if (StringUtil.isEmpty(addParameterForm.getValue(FILE_PATH)
                                               .trim())) {
            addParameterForm.setErrorMessage(FILE_PATH,
                "This Field is required.");
            validationStatus = false;
        }

        if ("search".equals(insertion_point)) {

            // SEARCH is required.
            if (StringUtil.isEmpty(addParameterForm.getValue(SEARCH))) {
                addParameterForm.setErrorMessage(SEARCH,
                    "This Field is required.");
                validationStatus = false;
            }
        }

        return validationStatus;
    }

    protected void updateRowVisibility()
    {
        String insertion = addParameterForm.getValue(INSERTION_POINT);

        addParameterForm.setRowVisible(SEARCH, "search".equals(insertion));
        addParameterForm.setRowVisible(REGEX, "search".equals(insertion));
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
        Map<String, String> actualParams  = new HashMap<String, String>();
        Map<String, String> addFormValues = addParameterForm.getValues();

        actualParams.put(FILE_PATH, addFormValues.get(FILE_PATH));
        actualParams.put(TEXT, addFormValues.get(TEXT));
        actualParams.put(INSERTION_POINT, addFormValues.get(INSERTION_POINT));
        actualParams.put(REGEX, addFormValues.get(REGEX));
        actualParams.put(SEARCH, addFormValues.get(SEARCH));

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
                    TEXT,
                    INSERTION_POINT,
                    REGEX,
                    SEARCH
                }) {
            addParameterForm.setValue(key,
                StringUtil.nullToEmpty(params.get(key)));
        }

        // REGEX is also an easy direct mapping (but
        // to the top form).
        String regex = params.get(REGEX);

        if (regex == null) {
            regex = "0";
        }

        addParameterForm.setValue(REGEX, regex);
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
        extends UiBinder<Widget, AddParameterPanel> { }
}

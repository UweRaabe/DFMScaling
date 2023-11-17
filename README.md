# DFMScaling
Stores DFM files as 96 DPI while allowing to design in High DPI.

The approach used registers a notifier to each open DFM editor to intercept its AfterSave event. It loads the just saved DFM file, creates a seprate instance from it, scales it down to 96 dpi and saves overwriting the previous DFM file.

That implies that only the written DFM is modified, while the internal representation stays intact. Especially showing a _form as text_ still shows the values in the designer (i.e. in High DPI).

You get the best user experience when setting the _VCL Designer High DPI_ Mode to _Automatic_. This also allows to disable the designer _Mimic the system style_ without the weird look when in _Low DPI_ mode.

The downscaling is also done when the mode is set to User Editable. This may be made configurable in a future version.

If the down scaling is not feasible for some project, the package can be disabled in the project options _Packages_ dialog.

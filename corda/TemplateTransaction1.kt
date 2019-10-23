val txBuilderNoNotary: TransactionBuilder = TransactionBuilder()

// add components to transaction builder using .withItems()
txBuilder.withItems(
// Inputs, as ``StateAndRef``s that reference the outputs of previous transactions
ourStateAndRef,
// Outputs, as ``StateAndContract``s
ourOutput,
// Commands, as ``Command``s
ourCommand,
// Attachments, as ``SecureHash``es
ourAttachment,
// A time-window, as ``TimeWindow``
ourTimeWindow
)
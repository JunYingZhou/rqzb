import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../data/renqing_record.dart";

Future<int?> showEditRecordAmountDialog({
  required BuildContext context,
  required RenqingRecord record,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _EditRecordAmountDialog(record: record),
  );
}

class _EditRecordAmountDialog extends StatefulWidget {
  const _EditRecordAmountDialog({
    required this.record,
  });

  final RenqingRecord record;

  @override
  State<_EditRecordAmountDialog> createState() =>
      _EditRecordAmountDialogState();
}

class _EditRecordAmountDialogState extends State<_EditRecordAmountDialog> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isReceived => widget.record.amount >= 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.record.amount.abs().toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    Navigator.of(context).pop(int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("修改金额"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.record.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _isReceived ? "保留为收礼记录，仅修改金额。" : "保留为随礼记录，仅修改金额。",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "金额",
                  prefixText: "￥",
                  hintText: "请输入正整数金额",
                ),
                validator: (value) {
                  final amount = int.tryParse(value?.trim() ?? "");
                  if (amount == null || amount <= 0) {
                    return "请输入大于 0 的整数金额";
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("取消"),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text("保存"),
        ),
      ],
    );
  }
}
